#!/bin/bash

if [ ! -n "$1" ] ;then
   log_file=monitor.log
else
   log_file=$1
fi
i=1
# second arg is not null then delete the logfile
if [ "$2" ] ;then
   rm $log_file
fi
exec 1>>$log_file
exec 2>>$log_file

while true
do
  time=`date "+%Y-%m-%d %H:%M:%S"`
  
  cpuuse=`top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{ len=split($1, vs, ","); v=vs[len]; sub("%", "", v); printf  100-v }'`
  meminfo=`free -m|grep Mem|awk '{print ($3-$6-$7)/$2*100}'`
  diskinfo=`df -h | grep /dev/sda1|awk '{print $5}'|cut -c 1-2`
  mysqlinfo=`top -b -n2 |fgrep mysqld|tail -1`
  mysqlres=`echo "$mysqlinfo"|awk '{print $6}'|
  rx=`ifconfig eth2 | sed -n "8p" | awk '{print $2}' | cut -c 7-`
  tx=`ifconfig eth2 | sed -n "8p" | awk '{print $6}' | cut -c 7-`
  sleep 2
done
echo cpuuse

echo "monitor finished"

