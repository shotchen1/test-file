CREATE DATABASE IF NOT EXISTS `oauth_server` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci; 
USE `oauth_server`;
set @schema="oauth_server";
#定义升级记录表id值，每次升级添加一条记录
set @upgrade_id = 0;
set @upgrade_fail_count = 0;
#创建升级数据库脚本
drop procedure if exists add_column;
drop procedure if exists drop_column;
drop procedure if exists add_index;
drop procedure if exists add_data;
drop procedure if exists update_upgrade_record;
delimiter //
create procedure add_column(in tbname varchar(128),in tbcolumnname varchar(128),in tbcolumntype varchar(64),in tbdefault varchar(128),in tbcomment varchar(512)) 
begin
  DECLARE exit HANDLER FOR SQLSTATE '42S21' SET @upgrade_fail_count = @upgrade_fail_count+1;
  set @v_state=0;
  set @v_type=null;
  set @v_sql = concat("select 1,column_type into @v_state,@v_type FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='",@schema,"' AND table_name='",tbname,"' AND COLUMN_NAME='",tbcolumnname,"'");
  prepare stmt from @v_sql;
  execute stmt;
  
  #查看是否字段已存在
  if @v_state = 0 then
	case tbcolumntype
	     when 'timestamp' then set @v_sql = concat("alter table ",tbname," add ",tbcolumnname," ",tbcolumntype," not null default ",tbdefault," comment '",tbcomment,"'");
	     else set @v_sql = concat("alter table ",tbname," add ",tbcolumnname," ",tbcolumntype," not null default '",tbdefault,"' comment '",tbcomment,"'");
	end case;
	prepare stmt from @v_sql;
	execute stmt;
	select @v_sql;
  elseif @v_type <> tbcolumntype then
	set @v_sql = concat("alter table ",tbname," change ",tbcolumnname," ",tbcolumnname," ",tbcolumntype," not null default '",tbdefault,"' comment '",tbcomment,"'");
	prepare stmt from @v_sql;
	execute stmt;
  else
	select concat("not need modifycolumn ",tbcolumnname);
  end if;
  deallocate prepare stmt; 
end
//
create procedure drop_column(in tbname varchar(128),in tbcolumnname varchar(128)) 
begin
  DECLARE exit HANDLER FOR SQLSTATE '42S21' SET @upgrade_fail_count = @upgrade_fail_count+1;
  set @v_state=0;
  set @v_sql = concat("select 1 into @v_state FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='",@schema,"' AND table_name='",tbname,"' AND COLUMN_NAME='",tbcolumnname,"'");
  prepare stmt from @v_sql;
  execute stmt;
  
  #查看是否字段已存在
  if @v_state = 1 then
	set @v_sql = concat("alter table ",tbname," drop ",tbcolumnname);
	prepare stmt from @v_sql;
	execute stmt;
	select @v_sql;
  else
	select concat("column not exists,not need drop ",tbcolumnname);
  end if;
  deallocate prepare stmt; 
end
//
create procedure add_index(in tbname varchar(128),in tbcolumnname varchar(128),in tbindextype varchar(24)) 
begin
  DECLARE exit HANDLER FOR SQLSTATE '23000' SET @upgrade_fail_count = @upgrade_fail_count+1;
  set @v_state=0;
  set @v_idxname=null;
  #set @v_sql = concat("select 1,index_name into @v_state,@v_idxname FROM information_schema.statistics WHERE TABLE_SCHEMA='",@schema,"' AND table_name='",tbname,"' AND column_name='",tbcolumnname,"'");
  set @v_sql = "select 1,a.index_name into @v_state,@v_idxname from (select index_name,group_concat(column_name order by seq_in_index) as index_group_name from information_schema.statistics where table_schema=? and table_name=? group by index_name) a where a.index_group_name=?";
  prepare stmt from @v_sql;
  set @tbname = tbname;
  set @tbcolumnname = tbcolumnname;
  execute stmt using @schema,@tbname,@tbcolumnname;
  set @v_name = replace(tbcolumnname,",","_");
  set @v_newIdxname = concat("idx_",tbname,"_",@v_name);

  #查看是否索引已存在
  if @v_state = 0 then
	set @v_sql = concat("alter table ",tbname," add ",tbindextype," ",@v_newIdxname,"(",tbcolumnname,")");
	select @v_sql;
	prepare stmt from @v_sql;
	execute stmt;
  elseif @v_newIdxname <> @v_idxname then
	#先删除老索引，再创建新索引
        set @v_sql = concat("alter table ",tbname," drop index ",@v_idxname);
	select @v_sql;
	prepare stmt from @v_sql;
	execute stmt;
	set @v_sql = concat("alter table ",tbname," add ",tbindextype," ",@v_newIdxname,"(",tbcolumnname,")");
	select @v_sql;
	prepare stmt from @v_sql;
	execute stmt;
  else
	select concat("not need add index ",@v_idxname);
  end if;
  deallocate prepare stmt; 
end
//
create procedure add_data(in v_sql varchar(1024)) 
begin
  
end
//
create procedure update_upgrade_record(in upgrade_flag tinyint(2),in err_msg varchar(255)) 
begin
   if @upgrade_id>0 then
	#set @v_sql = concat("update upgrade_record set upgrade_detail=concat(upgrade_detail,'-','",err_msg,"'),is_success=",upgrade_flag,",fail_sql_count=",@upgrade_fail_count," where id=",@upgrade_id);
	#prepare stmt from @v_sql;
	#execute stmt;
	#deallocate prepare stmt; 
	#select @v_sql;
   end if; 
end
//
delimiter ;

#如果不存在则创建oauth_server客户端表
CREATE TABLE if not exists oauth_clients ( 
	`id` int(11) NOT NULL AUTO_INCREMENT comment '自增id',
	CONSTRAINT `id_pk` PRIMARY KEY (`id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;
#检查oauth_server客户端表字段
call add_column("oauth_clients","client_id","VARCHAR(128)","","客户id");
call add_column("oauth_clients","client_secret","varchar(128)","","客户秘钥");
call add_column("oauth_clients","redirect_uri","varchar(2000)","","客户重定向地址");
call add_column("oauth_clients","scope","VARCHAR(2000)","","申请的权限范围");
call add_column("oauth_clients","client_status","tinyint(2)","0","客户状态0可用99不可用");
call add_column("oauth_clients","client_codes_set_count","tinyint(2)","1","授权码使用次数0按过期时间其他为允许使用次数,缺省使用一次后删除");
#检查oauth_server客户端表索引
call add_index("oauth_clients","client_id","unique index");

#如果不存在则创建oauth_authorization_codes客户端授权码表
CREATE TABLE if not exists `oauth_authorization_codes` (
	`id` int(11) NOT NULL AUTO_INCREMENT comment '自增id', 
	CONSTRAINT `id_pk` PRIMARY KEY (`id`)
);
#检查字段
call add_column("oauth_authorization_codes","authorization_code","varchar(128)","","授权码");
call add_column("oauth_authorization_codes","client_id","varchar(128)","","客户id");
call add_column("oauth_authorization_codes","user_id","varchar(128)","","用户id");
call add_column("oauth_authorization_codes","redirect_uri","varchar(2000)","","客户重定向地址");
call add_column("oauth_authorization_codes","expires","timestamp","current_timestamp","过期时间");
call add_column("oauth_authorization_codes","scope","VARCHAR(2000)","","申请的权限范围");
call add_column("oauth_authorization_codes","client_access_ip","varchar(128)","","客户申请ip地址");
call add_column("oauth_authorization_codes","codes_set_count","tinyint(2)","1","授权码使用次数0按过期时间其他为允许使用次数,缺省使用一次后删除");
call add_column("oauth_authorization_codes","codes_use_count","tinyint(2)","0","授权码已使用次数");
#检查索引
call add_index("oauth_authorization_codes","authorization_code","unique index");

#如果不存在则创建访问令牌表
CREATE TABLE if not exists `oauth_access_tokens` (
	`id` int(11) NOT NULL AUTO_INCREMENT comment '自增id',
	CONSTRAINT `id_pk` PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
#检查字段
call add_column("oauth_access_tokens","access_token","VARCHAR(128)","","访问令牌");
call add_column("oauth_access_tokens","client_id","VARCHAR(128)","","客户id");
call add_column("oauth_access_tokens","user_id","VARCHAR(128)","","用户id");
call add_column("oauth_access_tokens","expires","timestamp","current_timestamp","过期时间");
call add_column("oauth_access_tokens","scope","VARCHAR(2000)","","申请的权限范围");
call add_column("oauth_access_tokens","token_set_count","tinyint(2)","0","访问令牌允许使用次数0按过期时间其他为允许使用次数");
call add_column("oauth_access_tokens","token_use_count","tinyint(2)","0","访问令牌已使用次数");
#检查索引
call add_index("oauth_access_tokens","access_token","unique index");

#如果不存在则创建刷新访问令牌表 
CREATE TABLE if not exists  `oauth_refresh_tokens` ( 
	`id` int(11) NOT NULL AUTO_INCREMENT comment '自增id',
	CONSTRAINT `id_pk` PRIMARY KEY (`id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;
#检查字段
call add_column("oauth_refresh_tokens","refresh_token","VARCHAR(128)","","更新令牌");
call add_column("oauth_refresh_tokens","client_id","VARCHAR(128)","","客户id");
call add_column("oauth_refresh_tokens","user_id","VARCHAR(128)","","用户id");
call add_column("oauth_refresh_tokens","expires","timestamp","current_timestamp","过期时间");
call add_column("oauth_refresh_tokens","scope","VARCHAR(2000)","","申请的权限范围");
call add_column("oauth_refresh_tokens","token_set_count","tinyint(2)","0","更新令牌允许使用次数0按过期时间其他为允许使用次数");
call add_column("oauth_refresh_tokens","token_use_count","tinyint(2)","0","更新令牌已使用次数");
#检查索引
call add_index("oauth_refresh_tokens","refresh_token","unique index");

#如果不存在则创建系统用户表 
CREATE TABLE if not exists  `oauth_user` ( 
	`id` int(11) NOT NULL AUTO_INCREMENT comment '自增id',
	CONSTRAINT `id_pk` PRIMARY KEY (`id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;
#检查字段
call add_column("oauth_user","user_id","VARCHAR(128)","","用户id");
call add_column("oauth_user","password","VARCHAR(128)","","用户密码");
call add_column("oauth_user","user_type","tinyint(2)","0","用户类型99为超级管理员");
call add_column("oauth_user","user_status","tinyint(2)","0","用户状态");
#检查索引
call add_index("oauth_user","user_id","unique index");
#添加数据
insert ignore into oauth_user(`id`,`user_id`,`password`,`user_type`) values(1,'auth_admin','21232f297a57a5a743894a0e4a801fc3',99)
,(2,'file_auth_admin','21232f297a57a5a743894a0e4a801fc3',0)
,(3,'maintenance_auth_admin','21232f297a57a5a743894a0e4a801fc3',0)
;

#如果不存在则创建系统用户属性表 
CREATE TABLE if not exists `oauth_user_profile` (
	`id` int(11) NOT NULL AUTO_INCREMENT comment '自增id',
	CONSTRAINT `id_pk` PRIMARY KEY (`id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;
#检查字段
call add_column("oauth_user_profile","uid","int(11)","0","用户id");
call add_column("oauth_user_profile","u_key","VARCHAR(128)","","用户参数");
call add_column("oauth_user_profile","u_value","VARCHAR(255)","","用户值");
call add_column("oauth_user_profile","u_comment","varchar(512)","","用户配置说明");
#检查索引
call add_index("oauth_user_profile","uid,u_key","unique index");

#如果不存在则创建授权权限表 
CREATE TABLE if not exists  `oauth_scope` ( 
	`id` int(11) NOT NULL AUTO_INCREMENT comment '自增id',
	CONSTRAINT `id_pk` PRIMARY KEY (`id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;
#检查字段
call add_column("oauth_scope","scope_name","VARCHAR(255)","","申请权限名称");
call add_column("oauth_scope","scope_detail","VARCHAR(512)","","申请权限详情");
call add_column("oauth_scope","scope_code","VARCHAR(255)","","申请权限唯一编号");
#检查索引
call add_index("oauth_scope","scope_code","unique index");
#添加数据
insert ignore into `oauth_scope`(`id`,`scope_name`,`scope_detail`,`scope_code`) values(1,'运维服务器完全权限','具有以下权限：访问运维服务器数据，获取运维服务器性能','maintenance_complete')
,(2,'企业管理服务器完全权限','具有以下权限：访问企业管理服务器数据，获取企业管理服务器性能','enterprise_complete')
,(3,'SIP服务器完全权限','具有以下权限：访问SIP服务器数据，获取SIP服务器性能','sip_complete')
,(4,'文件服务器完全权限','具有以下权限：访问文件服务器数据，获取文件服务器性能','file_complete')
,(5,'任务服务器完全权限','具有以下权限：访问任务服务器数据，获取任务服务器性能','task_complete')
,(6,'鉴权服务器完全权限','具有以下权限：访问鉴权服务器数据，获取鉴权服务器性能','oauth_complete')
,(7,'pms服务器完全权限','具有以下权限：获取pms服务器性能','pms_complete')
,(8,'信息服务器完全权限','具有以下权限：访问信息服务器数据，获取信息服务器性能','message_complete')
,(9,'缓存服务器完全权限','具有以下权限：获取缓存服务器性能','redis_complete')
,(10,'数据库服务器完全权限','具有以下权限：获取数据库服务器性能','database_complete')
,(11,'Api服务器完全权限','具有以下权限：访问Api服务器数据，获取Api服务器性能','api_complete')
,(12,'所有服务器完全权限','具有以下权限：访问所有服务器数据，获取服务器性能','all_complete')
;

#如果不存在则创建授权权限与用户对应表 
CREATE TABLE if not exists  `oauth_user_scope` ( 
	`id` int(11) NOT NULL AUTO_INCREMENT comment '自增id',
	CONSTRAINT `id_pk` PRIMARY KEY (`id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;
#检查字段
call add_column("oauth_user_scope","scope_id","int(11)","0","申请权限id");
call add_column("oauth_user_scope","uid","int(11)","0","用户id");
#检查索引
call add_index("oauth_user_scope","scope_id,uid","unique index");
#添加数据
insert ignore into `oauth_user_scope`(`id`,`scope_id`,`uid`) values(1,12,3)
,(2,4,2)
;

#如果不存在则创建系统参数表 
CREATE TABLE if not exists  `system_param` ( 
	`id` int(11) NOT NULL AUTO_INCREMENT comment '自增id',
	CONSTRAINT `id_pk` PRIMARY KEY (`id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;
#检查字段
call add_column("system_param","s_key","varchar(128)","","系统配置键");
call add_column("system_param","s_value","varchar(255)","","系统配置值");
call add_column("system_param","s_comment","varchar(512)","","系统配置说明");
#检查索引
call add_index("system_param","s_key","unique index");
#添加数据
insert ignore into `system_param`(id,s_key,s_value,s_comment) values(1,'AUTHORIZE_CODE_EXPIRE','600','鉴权码过期时间，单位秒，缺省10分钟')
,(2,'ACCESS_TOKEN_EXPIRE','604800','访问令牌过期时间，单位秒，缺省一个星期')
,(3,'REFRESH_TOKEN_EXPIRE','2592000','刷新令牌过期时间，单位秒，缺省30天，30天内保证有人使用，则不需要重新授权')
;

#如果不存在则创建系统事件表 
create table if not exists `server_event_log`(
	`id` int(11) unsigned auto_increment ,		
	primary key (id)
)engine=myisam default charset=utf8;
#检查字段
call add_column("server_event_log","log_detail","varchar(512)","","日志详情");
call add_column("server_event_log","log_creator","varchar(64)","","日志创建人");
call add_column("server_event_log","is_display","tinyint(2)","0","是否显示事件，0不显示1显示");
call add_column("server_event_log","log_key","varchar(64)","system","事件类型system系统，authorized鉴权，accessed获取访问令牌，refreshed刷新访问令牌");
call add_column("server_event_log","relation_id","int(11) unsigned","0","日志关联id");
call add_column("server_event_log","log_type","tinyint(2)","0","日志类型");
call add_column("server_event_log","log_level","tinyint(2)","0","日志级别，0debug1err2warn3info");
call add_column("server_event_log","create_time","int(10) unsigned","0","创建时间");
call add_column("server_event_log","modify_time","timestamp","CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP","修改时间");
#检查索引
#添加数据
insert into server_event_log(log_detail,log_creator,is_display,log_key,relation_id,log_type,log_level,create_time) values('升级鉴权服务器','updateoauth_server',1,'system',@upgrade_id,0,3,unix_timestamp());

#如果不存在则创建升级记录表 
CREATE TABLE if not exists  `oauth_scope` ( 
	`id` int(11) NOT NULL AUTO_INCREMENT comment '自增id',
	CONSTRAINT `id_pk` PRIMARY KEY (`id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;
#在升级表里加字段
create table if not exists upgrade_record(
	`id` int(11) unsigned auto_increment ,
	`is_success` tinyint(4) not null default 0 comment '升级是否成功0:成功其他失败',
	`upgrade_detail` varchar(512) not null default '' comment '升级详情', 
	`version_detail` varchar(512) not null default '' comment '版本详情', 
	`backup_sql_path` varchar(512) not null default '' comment '升级前备份文件路径',
	`fail_sql_count` int(6) not null default 0 comment '失败sql次数',
	`create_time` int(10) unsigned DEFAULT 0 COMMENT '创建时间',
	`modify_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
	primary key (id)
)engine=myisam default charset=utf8;
call add_column("upgrade_record","version_detail","varchar(512)","","版本详情");
call update_upgrade_record(0,"升级鉴权服务器结束");
#清理升级数据库脚本
drop procedure if exists add_column;
drop procedure if exists drop_column;
drop procedure if exists add_index;
drop procedure if exists add_data;
drop procedure if exists update_upgrade_record;
/*1000000000*/
