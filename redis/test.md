# 设置值，获取值
* set foo "bar"
* get foo
* expire foo 120
* ttl foo 查询过期时间 返回-2值不存在 -1 值永不过期

# 自增变量
* set connections 10
* incr connections
* del connections

# list 队列
* rpush friends "alice" 添加到队尾
* rpush friends "bob"
* lpush friends "sam" 添加到队首
* lrange friends 0 -1 获取全部队列
* lrange friends 0 1 获取0-1
* llen friends 队列长度
* lpop friends 弹出首个对象
* rpop friends 弹出队尾对象

# set 与list相似，但没有顺序且对象只能出现一次
* sadd superpowers "flight"   添加值
* sadd superpowers "x-ray vision"
* sadd superpowers "reflexes"  
* srem superpowers "reflexes"  删除值
* sismember superpowers "reflexes"  判断是否存在0不存在1存在
* smembers superpowers
* sadd birdpowers "flight"
* sadd birdpowers "pecking"
* sunion superpowers birdpowers 合并set
# sorted set 可排序set
