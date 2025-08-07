/*
 create tables for integration, login accounts and menus
 */
create table sys_account (
  account_id varchar(100) not null primary key,
  username varchar(100),
  realname varchar(100) not null,
  phonenumber varchar(100) not null,
  passwd varchar(100) not null,
  menu_role varchar(100) not null,
  valid varchar(1) not null
);

create table sys_token (
  access_token varchar(1000) not null primary key,
  refresh_token varchar(1000) not null,
  client_id varchar(100) not null,
  account_id varchar(100) not null,
  ip varchar(100) not null
);

create table sys_menu (
  menu_url varchar(100) not null primary key,
  menu_name varchar(100) not null,
  rank integer,
  parent varchar(100),
  directory varchar(1) not null,
  valid varchar(1) not null
);

create table sys_menu_role (
  uuid varchar(100) not null primary key,
  menu_role varchar(100) not null,
  menu_url varchar(100) not null
);

/*
 assets or resources
 */
create table res_grant_team (
  uuid varchar(100) not null,
  account_id varchar(100) not null,
  team_id varchar(100) not null
);

create table res_grant_project (
  uuid varchar(100) not null,
  account_id varchar(100) not null,
  project_id varchar(100) not null,
  class_id integer not null
);

create table res_team (
  team_id varchar(100) not null primary key,
  team_name varchar(100) not null
);

create table res_class (
  class_id integer not null primary key,
  class_name varchar(100)
);

create table res_project (
  project_id varchar(100) not null primary key,
  project_name varchar(100) not null,
  team_id varchar(100) not null,
  note varchar(100)
);

create table res_db (
  db_id varchar(100) not null primary key,
  db_name varchar(100) not null,
  project_id varchar(100) not null,
  product varchar(100) not null,
  note varchar(100)
);

create table res_machine (
  main_ip varchar(100) not null primary key,
  os varchar(100) not null,
  mac_address varchar(100),
  hostname varchar(100),
  note varchar(100)
);

create table res_machine_detail (
  main_ip varchar(100) not null primary key,
  os varchar(100),
  mac_address varchar(100),
  hostname varchar(100),
  cpu varchar(100),
  memory varchar(100),
  disk varchar(100),
  note varchar(100)
);

-- for servers that have multiple ips
-- use one as main_ip and associate the other ips to main_ip
create table res_other_ip (
  other_ip varchar(100) not null primary key,
  main_ip varchar(100) not null,
  note varchar(100)
);

create table res_project_machine (
  uuid varchar(100) not null primary key,
  project_id varchar(100) not null,
  main_ip varchar(100) not null,
  note varchar(100)
);

create table res_db_machine (
  uuid varchar(100) not null primary key,
  db_id varchar(100) not null,
  main_ip varchar(100) not null,
  note varchar(100)
);

create table res_passwd_machine (
  uuid varchar(100) not null primary key,
  main_ip varchar(100) not null,
  username varchar(100) not null,
  passwd varchar(100) not null,
  encrypted varchar(1) not null,
  class_id integer not null,
  note varchar(100)
);

create table res_passwd_db (
  uuid varchar(100) not null primary key,
  db_id varchar(100) not null,
  username varchar(100) not null,
  passwd varchar(100) not null,
  encrypted varchar(1) not null,
  class_id integer not null,
  note varchar(100)
);

create table res_passwd_address (
  uuid varchar(100) not null primary key,
  project_id varchar(100) not null,
  address varchar(100) not null,
  username varchar(100) not null,
  passwd varchar(100) not null,
  encrypted varchar(1) not null,
  class_id integer not null,
  note varchar(100)
);

create table res_passwd_other (
  uuid varchar(100) not null primary key,
  project_id varchar(100) not null,
  username varchar(100) not null,
  passwd varchar(100) not null,
  encrypted varchar(1) not null,
  class_id integer not null,
  note varchar(100)
);

/*
 deployment details
 used by monitor
 */
create table dep_ogg (
  uuid varchar(100) not null primary key,
  ip varchar(100) not null,
  port varchar(100) not null,
  directory varchar(100) not null,
  note varchar(100) not null
);

create table dep_linux_service (
  uuid varchar(100) not null primary key,
  ip varchar(100) not null,
  service_name varchar(100) not null,
  command_status varchar(100) not null,
  running_regexp varchar(100) not null,
  product varchar(100),
  product_version varchar(100),
  note varchar(100)
);

create table dep_nfs_client (
  uuid varchar(100) not null primary key,
  ip varchar(100) not null,
  nfs_path varchar(100) not null,
  local_path varchar(100) not null,
  project_id varchar(100) not null,
  note varchar(100)
);

create table dep_was_program (
  uuid varchar(100) not null primary key,
  program varchar(100) not null,
  protocol varchar(100) not null,
  ip varchar(100) not null,
  port varchar(100) not null,
  note varchar(100)
);

create table dep_weblogic (
  uuid varchar(100) not null primary key,
  ip varchar(100) not null,
  username varchar(100) not null,
  bsu_dir varchar(100) not null,
  prod_dir varchar(100) not null,
  cache_dir varchar(100) not null
);
