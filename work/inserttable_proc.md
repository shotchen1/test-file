 drop procedure auto_insert_tbdata;

 delimiter //

create procedure auto_insert_tbdata(tablename varchar(64),datacount int(10),eid int(11) unsigned)
begin
   declare sqlstart int(11) unsigned;
   declare sqlend int(11) unsigned;
   declare vsql varchar(1000);
   declare vfield varchar(500);
   declare stmt varchar(2000);
   declare vstart_time int(11) unsigned;
   declare vend_time int(11) unsigned;
   declare vval varchar(500);
   select unix_timestamp() into sqlstart;
   case tablename
        when 'talk_call_record' then 
	      set vfield='id,eid,call_type,dialing,incoming,incoming_member' ;
	when 'e_sip_callcenter_history' then
	      set vfield='id';
	else
	      set vfield='eid,call_type,dialing,incoming,start_time,end_time';
   end case;
   select unix_timestamp() into vend_time;
   insertlable:loop 
      set vstart_time=vend_time-1;
      set vval=concat(eid,',',2,',','1000',',','1001',',',vstart_time,',',vend_time);
      set vsql=concat('insert into ',tablename,'(',vfield,')',' values(',vval,')');
      set @sqlstr=vsql;
      prepare stmt from @sqlstr;
      execute stmt;
      set vend_time=vstart_time;
      if datacount > 0 then 
         set datacount=datacount-1;
         iterate insertlable; 
      else
         leave insertlable;
      end if;
   end loop insertlable;
   deallocate prepare stmt;
   select unix_timestamp() into sqlend;
   select sqlstart;
   select sqlend;
end//
delimiter ;
