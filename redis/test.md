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
* zadd hackers 1940 "alan key"
* zadd hackers 1980 "Grace hopper"
* zadd hackers 1945 "richard stallman"
* zadd hackers 1944 "macker"
* zrange hackers 0 -1

# hashes
* hset user:1000 name "john smith"
* hset user:1000 email "john.smith@example.com"
* hset user:1000 password "s3cret"
* hgetall user:1000 
* HMSET user:1001 name "Mary Jones" password "hidden" email "mjones@example.com"
* SET user:1000 visits 10
* HINCRBY user:1000 visits 1 加1
* hdel user:1000 visits 删除值
