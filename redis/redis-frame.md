# 安装
参照 [redis安装](install.md)

# 配置
* redis配置

```shell
vi redis.conf
bind 10.0.0.23
daemonize yes
logfile "/var/pbx/tmp/Logs/redis/redis_6379.log"
dbfilename dump_6379.rdb
//生产环境
rename-command FLUSHALL ""
rename-command FLUSHDB ""
rename-command KEYS ""
rename-command CONFIG ""
maxmemory 1gb //占用的最大内存
appendonly yes
appendfilename "appendonly_6379.aof"
requirepass "prettydogKnockTheDoor" //需要密码才能访问
将redis加入到系统自启动的脚本中
```

* iptable配置

>考虑到安全，不允许外网用户访问redis
```
10.0.0.0/24 表示C类地址 24掩码前面的0
iptables -A INPUT ! -s 10.0.0.0/24 -p tcp --dport 6379 -j DROP //拒绝所有非本网段的机器访问redis
iptables -A INPUT ! -s 10.0.0.0/24 -p udp --dport 6379 -j DROP
保存iptables规则下次启动时自动启动规则
iptables-save > /etc/iptables.up.rules //保存规则
vi /etc/network/interfaces
pre-up iptables-restore < /etc/iptables.up.rules  //恢复规则
iptables -F
重启网络
/etc/init.d/networking restart
iptables -L -v
重启机器
iptables -L -v
可以看到刚刚配置的规则都在
```


# 测试

## redis数据类型测试
* 参照 [redis测试](test.md)

## 安全测试
* 只有使用密码才能访问
```
root@1604developer:/var# telnet 10.0.0.23 6379
Trying 10.0.0.23...
telnet: Unable to connect to remote host: Connection refused
root@1604developer:/var# telnet 10.0.0.23 6379
Trying 10.0.0.23...
Connected to 10.0.0.23.
Escape character is '^]'.
keys *
-NOAUTH Authentication required.
auth prettydogknockthedoor
-ERR invalid password
auth prettydogKnockTheDoor
+OK
keys *
*0

```
* 指定ip才能访问
```
iptables -L -v --line-num
配置iptables只允许10.0.0.1-32的ip地址访问redis
iptables -A INPUT ! -s 10.0.0.0/27 -p tcp --dport 6379 -j DROP
iptables -A INPUT ! -s 10.0.0.0/27 -p udp --dport 6379 -j DROP
在本机访问
root@ubuntu1204base:/home/cxl/redis/redis-3.2.6# telnet 10.0.0.23 6379
Trying 10.0.0.23...
Connected to 10.0.0.23.
Escape character is '^]'.
auth prettydogKnockTheDoor
+OK
keys *
*0
在10.0.0.237机器访问
root@php1 16:51:00:~# telnet 10.0.0.23 6379
Trying 10.0.0.23...
如果策略修改为
iptables -A INPUT ! -s 10.0.0.0/27 -p tcp --dport 6379 -j REJECT
iptables -A INPUT ! -s 10.0.0.0/27 -p udp --dport 6379 -j REJECT
再次在10.0.0.237机器访问
root@php1 16:53:23:~# telnet 10.0.0.23 6379
Trying 10.0.0.23...
telnet: Unable to connect to remote host: Connection refused
```


## 数据恢复测试
* kill redis 进程
```
root@ubuntu1204base:/home/cxl/redis/redis-3.2.6# src/redis-cli -h 10.0.0.23
10.0.0.23:6379> auth prettydogKnockTheDoor
OK
10.0.0.23:6379> set "first Key" "first Value"
OK
10.0.0.23:6379> get "first Key"
"first Value"
10.0.0.23:6379> quit
root@ubuntu1204base:/home/cxl/redis/redis-3.2.6# ps -aux |grep redis
Warning: bad ps syntax, perhaps a bogus '-'? See http://procps.sf.net/faq.html
root      4418  0.1  0.3  36124  1564 ?        Ssl  17:54   0:00 src/redis-server 10.0.0.23:6379
root      4497  0.0  0.1   9380   936 pts/2    S+   17:57   0:00 grep --color=auto redis
root@ubuntu1204base:/home/cxl/redis/redis-3.2.6# kill 4418
root@ubuntu1204base:/home/cxl/redis/redis-3.2.6# src/redis-server redis.conf
root@ubuntu1204base:/home/cxl/redis/redis-3.2.6# src/redis-cli -h 10.0.0.23
10.0.0.23:6379> keys *
(error) NOAUTH Authentication required.
10.0.0.23:6379> auth prettydogKnockTheDoor
OK
10.0.0.23:6379> get "first Key"
"first Value"
10.0.0.23:6379> quit

```
* 重启redis进程，查看redis数据
```
root@ubuntu1204base:/home/cxl/redis/redis-3.2.6# reboot
root@ubuntu1204base:/home/cxl/redis/redis-3.2.6# src/redis-server redis.conf
root@ubuntu1204base:/home/cxl/redis/redis-3.2.6# src/redis-cli -h 10.0.0.23
10.0.0.23:6379> auth prettydogKnockTheDoor
OK
10.0.0.23:6379> get "first Key"
"first Value"
10.0.0.23:6379> 

```
## 性能测试
* 内存占用测试
```
vi redis.conf
maxmemory 1m //为了测试方便设置为1mb
vi addKey.sh 
     # !/usr/bin/bash

    echo "AUTH prettydogKnockTheDoor"
    sleep 1

    outstr=""
    value10="1"
    j=700
    while [ $j -gt 690 ]
    do
        for i in {100..199}
        do
            outstr="${outstr}set key$j-$i ${value10}\r\n"
       done
       printf "$outstr"
       outstr=""
       j=`expr $j - 1`
    done  
这个脚本往redis服务器加入1000个key，其中Key值10个字节，value值一个字节

10.0.0.23:6379> flushall //清空redis
10.0.0.23:6379> info
     # Memory
     used_memory:821552
     used_memory_human:803.70K
     看出来，redis初始状态就占用803.70k，所以设置1m最大内存，实际可用应该是200k左右
运行脚本插入1000个键值
./addkey.sh | nc 10.0.0.23 6379

10.0.0.23:6379> info
     # Memory
     used_memory:871184
     used_memory_human:850.77K
     
占用内存47k，所以11字节的key+value大概占用47字节的内存空间
修改一下脚本加入4000key
-OOM command not allowed when used memory > 'maxmemory'.
10.0.0.23:6379> dbsize
(integer) 3109
只加入了3109键值
used_memory:980120
used_memory_human:957.15K

```
* 大并发测试
```
50个客户端发送100000请求每个请求3个字节，看起来redis很给力
root@ubuntu1204base:/home/cxl/redis/redis-3.2.6# src/redis-benchmark -h 10.0.0.23
====== PING_INLINE ======
  100000 requests completed in 1.20 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.62% <= 1 milliseconds
99.93% <= 2 milliseconds
100.00% <= 2 milliseconds
83682.01 requests per second

====== PING_BULK ======
  100000 requests completed in 1.20 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

97.22% <= 1 milliseconds
99.98% <= 2 milliseconds
100.00% <= 2 milliseconds
83194.67 requests per second

====== SET ======
  100000 requests completed in 1.18 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

97.30% <= 1 milliseconds
100.00% <= 1 milliseconds
84889.65 requests per second

====== GET ======
  100000 requests completed in 1.22 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.78% <= 1 milliseconds
100.00% <= 1 milliseconds
81967.21 requests per second

====== INCR ======
  100000 requests completed in 1.25 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.40% <= 1 milliseconds
100.00% <= 1 milliseconds
79744.82 requests per second

====== LPUSH ======
  100000 requests completed in 1.35 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

95.57% <= 1 milliseconds
99.93% <= 2 milliseconds
100.00% <= 2 milliseconds
73909.83 requests per second

====== RPUSH ======
  100000 requests completed in 1.29 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.26% <= 1 milliseconds
99.94% <= 2 milliseconds
100.00% <= 2 milliseconds
77519.38 requests per second

====== LPOP ======
  100000 requests completed in 1.28 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.25% <= 1 milliseconds
99.99% <= 5 milliseconds
100.00% <= 5 milliseconds
78369.91 requests per second

====== RPOP ======
  100000 requests completed in 1.29 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.46% <= 1 milliseconds
99.96% <= 2 milliseconds
100.00% <= 2 milliseconds
77220.08 requests per second

====== SADD ======
  100000 requests completed in 1.39 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

95.35% <= 1 milliseconds
99.36% <= 2 milliseconds
99.74% <= 3 milliseconds
99.88% <= 4 milliseconds
99.94% <= 5 milliseconds
99.96% <= 6 milliseconds
99.98% <= 11 milliseconds
100.00% <= 17 milliseconds
71736.01 requests per second

====== SPOP ======
  100000 requests completed in 1.23 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.97% <= 1 milliseconds
100.00% <= 2 milliseconds
100.00% <= 2 milliseconds
81433.22 requests per second

====== LPUSH (needed to benchmark LRANGE) ======
  100000 requests completed in 1.24 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.80% <= 1 milliseconds
100.00% <= 1 milliseconds
80840.74 requests per second

====== LRANGE_100 (first 100 elements) ======
  100000 requests completed in 1.20 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.77% <= 1 milliseconds
100.00% <= 1 milliseconds
83333.33 requests per second

====== LRANGE_300 (first 300 elements) ======
  100000 requests completed in 1.24 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.71% <= 1 milliseconds
99.87% <= 2 milliseconds
99.96% <= 3 milliseconds
100.00% <= 4 milliseconds
100.00% <= 4 milliseconds
80515.30 requests per second

====== LRANGE_500 (first 450 elements) ======
  100000 requests completed in 1.28 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

95.97% <= 1 milliseconds
100.00% <= 2 milliseconds
100.00% <= 2 milliseconds
77881.62 requests per second

====== LRANGE_600 (first 600 elements) ======
  100000 requests completed in 1.28 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.21% <= 1 milliseconds
99.95% <= 2 milliseconds
100.00% <= 2 milliseconds
78308.54 requests per second

====== MSET (10 keys) ======
  100000 requests completed in 1.18 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.16% <= 1 milliseconds
99.93% <= 2 milliseconds
99.97% <= 3 milliseconds
99.98% <= 11 milliseconds
100.00% <= 11 milliseconds
84817.64 requests per second
```
* 监控性能
>top监控
```
   root@ubuntu1204base:/home/cxl/redis/redis-3.2.6#  top -b -p 16417 -n 2|egrep "16417|PID"|tail -2
   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND                                                                
   16417 root      20   0 42268 8980 1240 S  0.0  1.8   0:02.70 redis-server  
```
>redis-cli info监控
```
   root@ubuntu1204base:/home/cxl/redis/redis-3.2.6# src/redis-cli -h 10.0.0.23 -a prettydogKnockTheDoor info|grep used_memory
   used_memory:7470144
   used_memory_human:7.12M
   used_memory_rss:9023488
   used_memory_rss_human:8.61M
   used_memory_peak:7470144
   used_memory_peak_human:7.12M
   used_memory_lua:37888
   used_memory_lua_human:37.00K
```
# 代码示例

## predis

参照[predis安装](install.md# 使用predis)
## phpredis
