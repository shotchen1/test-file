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
```

* iptable配置

# 测试

## redis数据类型测试
* 参照 [redis测试](test.md)

## 安全测试
* 只有使用密码才能访问
* 指定ip才能访问

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
