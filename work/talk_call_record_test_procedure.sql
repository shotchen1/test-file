drop procedure simpletest;
 delimiter //
 create procedure simpletest()
 begin
   reset query cache;
   SELECT sum(duration_time) as stime,sum(duration_minute) as sminute,`outside_type` FROM `talk_call_record` WHERE ( `eid` = '997' ) GROUP BY outside_type;
   reset query cache;
   select id,call_type,dialing,incoming,start_time,duration_time from talk_call_record where eid=997 and (dialing like '%1000%' or incoming like '%1000%') and res_token <> "" order by  start_time desc limit 0,10;
   reset query cache; 
   SELECT `duration_time` FROM `talk_call_record` WHERE ( `res_token` = '45471c6f9db76ed1dcf7ce812b600df31481163525' ) LIMIT 1;
   reset query cache; 
   select count(*) from `talk_call_record` WHERE ( `eid` = '997' ) AND ( (`start_time` > 1480585500) AND (`start_time` < 1489485000) );
   reset query cache; 
   SELECT `id`,`eid`,`call_type`,`dialing`,`dialing_member`,`incoming`,`incoming_member`,`start_time`,`duration_time`,`duration_minute`,`call_state`,`pub_number`,`outside_type`,`outnumber` FROM `talk_call_record` WHERE ( `eid` = '997' ) AND ( (`start_time` > 1480585500) AND (`start_time` < 1489485000) ) ORDER BY start_time desc,cc_number LIMIT 0,20 ;
   reset query cache; 
   SELECT `id`,`eid`,`call_type`,`dialing`,`dialing_member`,`incoming`,`incoming_member`,`start_time`,`duration_time`,`duration_minute`,`call_state`,`pub_number`,`outside_type`,`outnumber` FROM `talk_call_record` WHERE ( `eid` = '997' ) AND ( (`start_time` > 1480585500) AND (`start_time` < 1489485000) ) ORDER BY start_time desc,cc_number LIMIT 100000,20 ;
   reset query cache; 
   select count(t.counts) cnt from (select count(*) counts from talk_call_record where eid=997 and res_token<>'' group by cc_number) t;
   reset query cache; 
   select max(id) from talk_sync where eid=997;
 end //
 delimiter ;
