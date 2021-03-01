
define year = '2017'

--��~�ɾ\
drop table tmp_kk;
create table tmp_kk as
select wpinno, to_char(transt, 'YYYYMMDD') transt, receiver, viewtype
from wpborrow
;


drop table tmp_aa1;
create table tmp_aa1 as
select wpinno
from logtable
where to_char(transdatetime, 'YYYY') = '&year' and comments in ('�ȥ��k��','�q�l���k��')
;

--��~�k��
drop table tmp_aa2;
create table tmp_aa2 as
select a.wpinno, substr(b.wpkind,1,1) wpkind1, b.wpkind, b.wptype
from tmp_aa1 a left join fpv.wprec@filescanfpv b
    on a.wpinno = b.wpinno
;

--�U�������k�ɼ�
drop table tmp_aa;
create table tmp_aa as
select wpkind1, count(*) cnt
from tmp_aa2
group by wpkind1
;


-- *** ���y�ᴿ�Q�ɾ\��� ***
with s1 as ( -- ���y�ᴿ�Q�ɾ\�����
    select count(*) cnt
    from barcodetable a
    where to_char(createtime, 'YYYY') = '&year' and exists (
        select ''
        from wpborrow b
        where a.barcodevalue = b.wpinno
    )
), s2 as ( -- ���y�����
    select count(*) cnt
    from barcodetable
    where to_char(createtime, 'YYYY') = '&year'
    
)
select a.cnt "���y�ɾ\��(�ȥ�/�q�l)", b.cnt ���y��, round((a.cnt/b.cnt),3)*100 �ʤ���
from s1 a, s2 b
;

select * from barcodetable;

-- *** �ɾ\�B���y�B�k�ɼ� ***
with s1 as (
    select barcodevalue, to_char(createtime, 'YYYY') createtime
    from barcodetable
    where to_char(createtime, 'YYYY') = '&year'
), s2 as ( --���y��
    select count(*) cnt
    from s1
), s3 as (
    select to_char(transt, 'YYYY') transt
    from wpborrow
    where to_char(transt, 'YYYY') = '&year'
), s4 as ( -- �ɾ\��
    select count(*) cnt
    from s3
), s5 as ( -- �k�ɼ�
    select count(*) cnt
    from logtable
    where to_char(transdatetime, 'YYYY') = '&year'
        and comments in ('�ȥ��k��','�q�l���k��')
)
select b.cnt �ɾ\��, a.cnt ���y��, c.cnt �k�ɼ�, round((b.cnt/a.cnt),3)*100 "�ɾ\/���y�ʤ���"
from s2 a, s4 b, s5 c
;



-- *** �~�׭��ɤ覡�έp ***
select substr(transt,1,4) �~��, 
        (case   when viewtype = 1 then '�ȥ�' 
                when viewtype = 2 then '�q�l'
                else '����'end) ���ɤ覡, 
        count(*) �ƶq
from tmp_kk
where substr(transt,1,4) = '&year'
group by substr(transt,1,4), viewtype
;

-- *** �������O�έp�]�j���^ ***
drop table tmp_kk1;
create table tmp_kk1 as
select a.*, substr(b.wpkind,1,1) wpkind1, b.wpcode, c.desc_, b.wpkind, b.wptype, 
    (case when d.wpname is not null then d.wpname else f.wpname end) wpname
from tmp_kk a
    left join fpv.wprec@filescanfpv b on substr(a.transt,1,4) = '&year' and a.wpinno = b.wpinno
    left join fpv.wpcode@filescanfpv c on b.wpcode = c.wpkind
    left join fpv.cirlmweb@filescanfpv d on b.wpkind = d.wpkind and b.wptype = d.wptype
    left join fpv.cirlm@filescanfpv e on b.wpkind = e.wpkind and b.wptype = e.wptype
    left join fpv.cirlmweb@filescanfpv f on e.cirlkind = f.cirlkind and e.cirlser = f.cirlser
where substr(a.transt,1,4) = '&year'
;

drop table tmp_kk2;
create table tmp_kk2 as
select wpinno, transt, receiver, viewtype,
    cast(wpkind1 as nvarchar2(20)) wpkind1,
    wpcode, desc_, wpkind, wptype, wpname
from tmp_kk1
;

select count(*)
from tmp_kk2
where wpname is null
;

with s1 as (
    select count(*) cntAll
    from tmp_kk2
), s2 as (
    select wpkind1, count(*) cnt
    from tmp_kk2
    group by wpkind1
), s3 as (
    select b.wpkind1, b.cnt, a.cntAll
    from s1 a, s2 b
), s4 as (
    select a.*, b.cnt cntWpkind1
    from s3 a left join tmp_aa b on a.wpkind1 = b.wpkind1
), s5 as (
    select 
    (case when wpkind1 = '0' then cast('������-�޲z��' as nvarchar2(20))
                when wpkind1 = '1' then cast('�s�y�~' as nvarchar2(20))
                when wpkind1 = '2' then cast('��y�~' as nvarchar2(20))
                when wpkind1 = '3' then cast('�a�x���@' as nvarchar2(20))
                when wpkind1 = '4' then cast('�a�x����' as nvarchar2(20))
                when wpkind1 = '5' then cast('����' as nvarchar2(20))
                when wpkind1 = '6' then cast('�S��' as nvarchar2(20))
                when wpkind1 = '7' then cast('�ջ�' as nvarchar2(20))
                when wpkind1 = '8' then cast('�N�~�w�w�O' as nvarchar2(20))
                when wpkind1 = '9' then cast('�i�@���c' as nvarchar2(20))
                else wpkind1 end) wpkind1,
        cntWpkind1, cnt, cntAll,
        (round((cnt/cntAll), 3)*100) percentage,
        (round((cnt/cntwpkind1), 3)*100) bwpkind1Perc
    from s4
)
select wpkind1 �������O, cntwpkind1 ���O�����`��, cnt �ɾ\�ƶq, cntAll �`���ɼ�, bwpkind1Perc ���O�Q�ɾ\�ʤ���, percentage �ɾ\�Ʀ��`�ɾ\�ʤ���
from s5
order by bwpkind1Perc desc, percentage desc
;


-- *** ���ɺ����έp�]�Ӷ��^ ***
with s1 as (
    select wpkind1, count(*) cntWpkindAll
    from tmp_kk2
    group by wpkind1
), s2 as (
    select wpkind1, wpname, count(*) cnt
    from tmp_kk2
    group by wpkind1, wpname
), s3 as (
    select b.wpkind1, b.wpname, b.cnt, a.cntWpkindAll
    from s1 a, s2 b
    where a.wpkind1 = b.wpkind1
), s4 as (
    select 
        wpkind1,
        wpname, cnt, cntWpkindAll,
        (round((cnt/cntWpkindAll), 3)*100) percentage
    from s3
), s5 as (
    select 
        (case when wpkind1 = '0' then cast('������-�޲z��' as nvarchar2(20))
                    when wpkind1 = '1' then cast('�s�y�~' as nvarchar2(20))
                    when wpkind1 = '2' then cast('��y�~' as nvarchar2(20))
                    when wpkind1 = '3' then cast('�a�x���@' as nvarchar2(20))
                    when wpkind1 = '4' then cast('�a�x����' as nvarchar2(20))
                    when wpkind1 = '5' then cast('����' as nvarchar2(20))
                    when wpkind1 = '6' then cast('�S��' as nvarchar2(20))
                    when wpkind1 = '7' then cast('�ջ�' as nvarchar2(20))
                    when wpkind1 = '8' then cast('�N�~�w�w�O' as nvarchar2(20))
                    when wpkind1 = '9' then cast('�i�@���c' as nvarchar2(20))
                    else wpkind1 end) wpkind1,
        wpname, cnt, cntWpkindAll, percentage
    from s4
    order by wpkind1, percentage desc
)
select  wpname ����, wpkind1 ���O, cnt �����p��, cntWpkindAll ���O�p��, percentage �ʤ���
from s5
;

drop table tmp_aa;
drop table tmp_aa1;
drop table tmp_aa2;
drop table tmp_kk;
drop table tmp_kk1;
drop table tmp_kk2;
