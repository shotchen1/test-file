drop procedure insert_talk_call_record;
delimiter //
create procedure insert_talk_call_record(in amount int(6),in eid int(11) unsigned,in starttime int(11) unsigned)
begin
    declare v_sql varchar(500);    ##--需要执行的SQL语句--
    declare startdialing  int(7); ##--主叫
    declare startincoming int(7); ##--被叫
    declare prefixdialing varchar(8); ##-- 主叫前缀
    declare prefixincoming varchar(8); ##-- 被叫前缀
    declare endtime int(11) unsigned; ##-- 结束时间
    declare durationtime int(8); ##--持续时间
    set durationtime = 10;
    set endtime = starttime + durationtime;
    set startdialing = 0;
    set startincoming = 0;
    set prefixdialing = '0258765';
    WHILE amount > 0 DO
      set v_sql = concat('insert into talk_call_record(eid,call_type,dialing,incoming,start_time,end_time,duration_time) values(',eid,',1,\'02566666001\',\'1865433322\',',starttime,',',endtime,',',durationtime,')');
      set @v_sql = v_sql;
      prepare stmt from @v_sql;
      execute stmt;
      deallocate prepare stmt;
      set amount = amount - 1;
    END WHILE;

end
//
delimiter ;

call insert_talk_call_record(5,15,1481040020);
