# 检查依赖
```
centerOs安装
sudo yum install make libtool autoconf subversion git cvs wget libogg-devel gcc gcc-c++ pkgconfig

安装环境ubuntu16.04
  g++ --version 
  gcc --version
  apt-cache show pkg-config |grep "^Version"
  apt-get install pkg-config
  apt-cache show libogg-dev |grep "^Version"
  apt-get install libogg-dev
  wget --version
  apt install cvs
  git --version
  apt-get install subversion
  apt install autoconf
  autoconf --version
  apt install libtool
  apt install openssl
  openssl version
  
  git clone https://github.com/cisco/libsrtp/
  cd libsrtp
  CFLAGS="-fPIC" ./configure --enable-pic && make && make install

  apt-get install speex
  apt-get install libspeex-dev
  apt install libspeexdsp-dev
  
  apt install yasm
  
  libvpx adds support for VP8 and is optional but highly recommended if you want support for video when using Google Chrome or Mozilla Firefox.
  apt install libvpx-dev
```

#  build "Doubango IMS Framework v2.0"
