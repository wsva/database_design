create or replace view v_res_passwd_machine as
select
  d.project_id,
  d.project_name,
  (
    select string_agg(ip, ', ')
    from (
      select a.main_ip as ip
      union
      select o0.other_ip as ip
      from res_other_ip o0
      where o0.main_ip = a.main_ip
    ) as sub_ips
  ) as address,
  a.note || ', ' || b.note || ', ' || c.note as note,
  a.username,
  a.passwd,
  a.uuid,
  a.encrypted,
  a.class_id,
  'res_passwd_machine' as table_name,
  d.team_id,
  a.main_ip
from
  res_passwd_machine a
  join res_project_machine b on a.main_ip = b.main_ip
  join res_machine c on a.main_ip = c.main_ip
  join res_project d on b.project_id = d.project_id;

create or replace view v_res_passwd_db as
select
  c.project_id,
  c.project_name,
  (
    select string_agg(ip, ', ')
    from (
      select d0.main_ip as ip
      from res_db_machine d0
      where d0.db_id = a.db_id
      union
      select o0.other_ip as ip
      from res_other_ip o0
      join res_db_machine d0 on o0.main_ip = d0.main_ip
      where d0.db_id = a.db_id
    ) as sub_ips
  ) as address,
  b.db_name || ',' || b.product || ',' || b.note as note,
  a.username,
  a.passwd,
  a.uuid,
  a.encrypted,
  a.class_id,
  'res_passwd_db' as table_name,
  c.team_id,
  a.db_id as db_id
from
  res_passwd_db a
  join res_db b on a.db_id = b.db_id
  join res_project c on b.project_id = c.project_id;

create or replace view v_res_passwd_address as
select
  p.project_id,
  p.project_name,
  pa.address,
  pa.note,
  pa.username,
  pa.passwd,
  pa.uuid,
  pa.encrypted,
  pa.class_id,
  'res_passwd_address' as table_name,
  p.team_id
from
  res_passwd_address pa
  join res_project p on pa.project_id = p.project_id;


create or replace view v_res_passwd_other as
select
  p.project_id,
  p.project_name,
  '' as address,
  po.note,
  po.username,
  po.passwd,
  po.uuid,
  po.encrypted,
  po.class_id,
  'res_passwd_other' as table_name,
  p.team_id
from
  res_passwd_other po
  join res_project p on po.project_id = p.project_id;


create or replace view v_res_passwd_all as 
select p.project_id, p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted, p.class_id, p.table_name, p.team_id
from v_res_passwd_machine p union
select p.project_id, p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted, p.class_id, p.table_name, p.team_id
from v_res_passwd_db p union
select p.project_id, p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted, p.class_id, p.table_name, p.team_id
from v_res_passwd_address p union
select p.project_id, p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted, p.class_id, p.table_name, p.team_id
from v_res_passwd_other p;

create or replace view v_res_grant_by_team as
select t.account_id, p.project_id, p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted
  from res_grant_team t, v_res_passwd_all p
 where t.team_id = p.team_id;

create or replace view v_res_grant_by_project as
select t.account_id, p.project_id, p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted
  from res_grant_project t, v_res_passwd_all p
 where t.project_id = p.project_id
 and t.class_id >= p.class_id;

create or replace view v_res_all_granted_passwd as
select g.account_id, g.project_id, g.project_name, g.address, g.note, g.username, g.passwd, g.uuid, g.encrypted
  from v_res_grant_by_team g
union
select g.account_id, g.project_id, g.project_name, g.address, g.note, g.username, g.passwd, g.uuid, g.encrypted
  from v_res_grant_by_project g;

create or replace view v_res_all_encrypted_passwd as
select p.table_name, p.uuid, p.passwd 
  from v_res_passwd_all p 
 where p.encrypted = 'Y';

create or replace view v_res_all_plain_passwd as
select p.table_name, p.uuid, p.passwd
  from v_res_passwd_all p 
 where p.encrypted = 'N';

create or replace view v_res_all_machine as
select
  m.main_ip,
  (
    select string_agg(p0.project_name || ': ' || pm0.note, ', ') || ', ' || m.note
    from res_project_machine pm0
    join res_project p0 on pm0.project_id = p0.project_id
    where pm0.main_ip = m.main_ip
  ) as note
from
  res_machine m;

  
create or replace view v_res_all_ip as
select
  a.main_ip as ip,
  (
    select string_agg(note, ', ')
    from (
      select p0.project_name || ': ' || pm0.note as note
      from res_project_machine pm0
      join res_project p0 on pm0.project_id = p0.project_id
      where pm0.main_ip = a.main_ip

      union

      select d0.db_name || ': ' || d0.note || ', ' || dm0.note as note
      from res_db_machine dm0
      join res_db d0 on dm0.db_id = d0.db_id
      where dm0.main_ip = a.main_ip
    ) as sub_notes
  ) as note
from
  v_res_all_machine a
union
select a.other_ip as ip, a.main_ip || ', ' || a.note as note
from res_other_ip a;

create or replace view v_dep_all as
select distinct a.ip, 'OGG' as dep from dep_ogg a
union
select distinct a.ip, 'LinuxService' as dep from dep_linux_service a
union
select distinct a.main_ip as ip, b.product as dep
from res_db_machine a
join res_db b on a.db_id = b.db_id
union
select distinct a.ip, 'NFSClient' as dep from dep_nfs_client a
union
select distinct a.ip, 'Weblogic' as dep from dep_weblogic a;
