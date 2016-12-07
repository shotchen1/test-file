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
echo "************excute $i ****************"
echo "***************** "`date`"*****************"
echo "****** memory usage top 10 *******"
echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
ps aux|sort -k4nr |head -n 10

echo "****** cpu usage top 10 *******"
echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
ps aux|sort -k3nr |head -n 10

echo "****** apache count *******"
ps aux|grep "apache" |grep -v "grep"|wc -l

echo "****** top status *******"
top -b -n 2|egrep "top -|Tasks:|Cpu|Mem:|Swap:"|tail -5

echo "****** free status *******"
free

echo "****** df status *******"
df

echo "****** mysql processlist *****"
mysql -u root -p123456 -e "show processlist"

let i+=1
#if [ $i -gt 2 ]
#then
#	break;
#fi
sleep 1
done

echo "monitor finished"

