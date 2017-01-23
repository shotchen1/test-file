# depend lib
  http://oversip.net/documentation/2.0.x/installation/other_operating_systems/
  
* apt install ruby
* apt  install ruby-dev
* gem -v &&  make --version && gcc --version && g++ --version && openssl version
* apt install libev4

# install oversip
* gem install oversip

# 在ubuntu12.04上安装
* echo "deb http://deb.versatica.com precise main" > /etc/apt/sources.list.d/versatica.list
* wget -O - http://deb.versatica.com/deb.versatica.com.key | apt-key add -
* apt-get update
* apt-get install oversip
