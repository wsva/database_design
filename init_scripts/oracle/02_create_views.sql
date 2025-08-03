create or replace view was.v_res_passwd_machine as 
SELECT D.PROJECT_NAME PROJECT_NAME,
       (SELECT LISTAGG(IP, ', ')
          FROM (SELECT A.MAIN_IP IP
                  FROM DUAL
                UNION
                SELECT O0.OTHER_IP IP
                  FROM WAS.RES_OTHER_IP O0
                 WHERE O0.MAIN_IP = A.MAIN_IP)) ADDRESS,
       A.NOTE || ', ' || B.NOTE || ', ' || C.NOTE NOTE,
       A.USERNAME,
       A.PASSWD,
       A.UUID,
       A.ENCRYPTED,
       A.CLASS_ID,
       'was.res_passwd_machine' TABLE_NAME,
       D.TEAM_ID TEAM_ID,
       D.PROJECT_ID PROJECT_ID,
       A.MAIN_IP
  FROM WAS.RES_PASSWD_MACHINE  A,
       WAS.RES_PROJECT_MACHINE B,
       WAS.RES_MACHINE         C,
       WAS.RES_PROJECT         D
 WHERE A.MAIN_IP = B.MAIN_IP
   AND A.MAIN_IP = C.MAIN_IP
   AND B.PROJECT_ID = D.PROJECT_ID;

create or replace view was.v_res_passwd_db as 
SELECT C.PROJECT_NAME PROJECT_NAME,
       (SELECT LISTAGG(IP, ', ')
          FROM (SELECT D0.MAIN_IP IP
                  FROM WAS.RES_DB_MACHINE D0
                 WHERE D0.DB_ID = A.DB_ID
                UNION
                SELECT O0.OTHER_IP IP
                  FROM WAS.RES_OTHER_IP O0, WAS.RES_DB_MACHINE D0
                 WHERE D0.DB_ID = A.DB_ID
                   AND O0.MAIN_IP = D0.MAIN_IP)) ADDRESS,
       B.DB_NAME || ',' || B.PRODUCT || ',' || B.NOTE NOTE,
       A.USERNAME,
       A.PASSWD,
       A.UUID,
       A.ENCRYPTED,
       A.CLASS_ID,
       'was.res_passwd_db' TABLE_NAME,
       C.TEAM_ID TEAM_ID,
       C.PROJECT_ID PROJECT_ID,
       A.DB_ID DB_ID
  FROM WAS.RES_PASSWD_DB A, WAS.RES_DB B, WAS.RES_PROJECT C
 WHERE A.DB_ID = B.DB_ID
   AND B.PROJECT_ID = C.PROJECT_ID;

create or replace view was.v_res_passwd_address as 
SELECT P.PROJECT_NAME PROJECT_NAME,
       PA.ADDRESS,
       PA.NOTE,
       PA.USERNAME,
       PA.PASSWD,
       PA.UUID,
       PA.ENCRYPTED,
       PA.CLASS_ID,
       'was.res_passwd_address' TABLE_NAME,
       P.TEAM_ID TEAM_ID,
       P.PROJECT_ID PROJECT_ID
  FROM WAS.RES_PASSWD_ADDRESS PA, WAS.RES_PROJECT P
 WHERE PA.PROJECT_ID = P.PROJECT_ID;

create or replace view was.v_res_passwd_other AS
SELECT P.PROJECT_NAME PROJECT_NAME,
       '' ADDRESS,
       PO.NOTE,
       PO.USERNAME,
       PO.PASSWD,
       PO.UUID,
       PO.ENCRYPTED,
       PO.CLASS_ID,
       'was.res_passwd_other' TABLE_NAME,
       P.TEAM_ID TEAM_ID,
       PO.PROJECT_ID PROJECT_ID
  FROM WAS.RES_PASSWD_OTHER PO, WAS.RES_PROJECT P
 WHERE PO.PROJECT_ID = P.PROJECT_ID;

create or replace view was.v_res_passwd_all as 
select
  p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted, p.class_id, p.table_name, p.team_id, p.project_id 
from
  was.v_res_passwd_machine p union
select
  p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted, p.class_id, p.table_name, p.team_id, p.project_id 
from
  was.v_res_passwd_db p union
select
  p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted, p.class_id, p.table_name, p.team_id, p.project_id 
from
  was.v_res_passwd_address p union
select
  p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted, p.class_id, p.table_name, p.team_id, p.project_id 
from
  was.v_res_passwd_other p;

create or replace view was.v_res_grant_by_team as
select t.account_id, p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted
  from was.res_grant_team t, was.v_res_passwd_all p
 where t.team_id = p.team_id;

create or replace view was.v_res_grant_by_project as
select t.account_id, p.project_name, p.address, p.note, p.username, p.passwd, p.uuid, p.encrypted
  from was.res_grant_project t, was.v_res_passwd_all p
 where t.project_id = p.project_id
 and t.class_id >= p.class_id;

create or replace view was.v_res_all_granted_passwd as
select g.account_id, g.project_name, g.address, g.note, g.username, g.passwd, g.uuid, g.encrypted
  from was.v_res_grant_by_team g
union
select g.account_id, g.project_name, g.address, g.note, g.username, g.passwd, g.uuid, g.encrypted
  from was.v_res_grant_by_project g;

create or replace view was.v_res_all_encrypted_passwd as
select p.table_name, p.uuid, p.passwd 
  from was.v_res_passwd_all p 
 where p.encrypted = 'Y';

create or replace view was.v_res_all_plain_passwd as
select p.table_name, p.uuid, p.passwd
  from was.v_res_passwd_all p 
 where p.encrypted = 'N';

create or replace view was.v_res_all_machine as 
SELECT M.MAIN_IP,
       (SELECT LISTAGG(P0.PROJECT_NAME || ': ' || PM0.NOTE, ', ') || ', ' ||
               M.NOTE
          FROM WAS.RES_PROJECT_MACHINE PM0, WAS.RES_PROJECT P0
         WHERE PM0.MAIN_IP = M.MAIN_IP
           AND PM0.PROJECT_ID = P0.PROJECT_ID) NOTE
  FROM WAS.RES_MACHINE M;
  
create or replace view was.v_res_all_ip as 
SELECT A.MAIN_IP IP,
       (SELECT LISTAGG(NOTE, ', ')
          FROM ((SELECT (P0.PROJECT_NAME || ': ' || PM0.NOTE) NOTE
                   FROM WAS.RES_PROJECT_MACHINE PM0, WAS.RES_PROJECT P0
                  WHERE PM0.PROJECT_ID = P0.PROJECT_ID
                    AND PM0.MAIN_IP = A.MAIN_IP
                 UNION
                 SELECT (D0.DB_NAME || ': ' || D0.NOTE || ', ' || DM0.NOTE) NOTE
                   FROM WAS.RES_DB_MACHINE DM0, WAS.RES_DB D0
                  WHERE DM0.DB_ID = D0.DB_ID
                    AND DM0.MAIN_IP = A.MAIN_IP))) NOTE
  FROM WAS.V_RES_ALL_MACHINE A
UNION
SELECT A.OTHER_IP, A.MAIN_IP || ', ' || A.NOTE NOTE
  FROM WAS.RES_OTHER_IP A;
  
create or replace view was.v_dep_all as
SELECT DISTINCT a.IP, 'OGG' dep FROM was.DEP_OGG a
union
SELECT DISTINCT a.IP, 'LinuxService' dep FROM was.DEP_LINUX_SERVICE a
union
SELECT DISTINCT a.Main_IP IP, b.PRODUCT dep FROM was.RES_DB_MACHINE a, was.res_db b
where a.DB_ID = b.DB_ID
union
SELECT DISTINCT a.IP, 'NFSClient' dep FROM was.DEP_NFS_CLIENT a
union
SELECT DISTINCT a.IP, 'Weblogic' dep FROM was.DEP_WEBLOGIC a;
