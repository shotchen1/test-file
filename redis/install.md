# 安装redis  
---
* $ wget http://download.redis.io/releases/redis-3.2.6.tar.gz
* $ tar xzf redis-3.2.6.tar.gz
* $ cd redis-3.2.6
* $ make
* $ src/redis-server 运行redis服务
* $ src/redis-cli
* redis> set foo bar
* OK
* redis> get foo
* "bar"  

# 使用predis
---
* 好处是不需要安装php扩展，直接require就行了
* git clone git://github.com/nrk/predis.git
* wget https://github.com/nrk/predis/archive/v1.1.1.tar.gz
