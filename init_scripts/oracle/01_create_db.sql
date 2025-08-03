/*
 create tablespace and user
 */
create tablespace was_data datafile '/data/u01/app/oracle/oradata/wsva/was_data_01.dbf' size 200M;

create user was identified by xxxxxxx default tablespace was_data;
grant create session to was;
grant unlimited tablespace to was;
grant create table to was;
grant select any table to was;
grant insert any table to was;
grant update any table to was;
grant delete any table to was;