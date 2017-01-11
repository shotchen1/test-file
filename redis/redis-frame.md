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
* 重启redis进程，查看redis数据

## 性能测试
* 最大内存测试
* 大并发测试
* 监控性能
** 监控内存

# 代码示例

## predis

参照[predis安装](install.md# 使用predis)
## phpredis
