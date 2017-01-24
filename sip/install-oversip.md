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

* apt-get install ruby-rvm
* rvm get master
* rvm -v

* gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
* sudo apt-get --purge remove ruby-rvm
* sudo rm -rf /usr/share/ruby-rvm /etc/rvmrc /etc/profile.d/rvm.sh
* \curl -L https://get.rvm.io | bash -s stable --ruby --autolibs=enable --auto-dotfiles
* apt-get install oversip
* oversip_bin_path="$(dirname $(gem which oversip))/../bin"
* ls ${oversip_bin_path}/oversip
* oversip --help
* oversip --config-dir /usr/local/etc/oversip/
