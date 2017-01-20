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
  
  apt-get install clang # c++编译工具
  cd libyuv
  make -f linux.mk CXX=clang++
  clang++ -O2 -fomit-frame-pointer -Iinclude/ -Iutil/ -o convert util/convert.cc libyuv.a
  
  apt install libopencore-amrwb0
  apt install libopencore-amrnb0
  apt install libopencore-amrnb-dev
  apt install libopencore-amrwb-dev
  
  wget http://downloads.xiph.org/releases/opus/opus-1.0.2.tar.gz
  tar -xvzf opus-1.0.2.tar.gz
  cd opus-1.0.2
  ./configure --with-pic --enable-float-approx && make && make install
  
  wget http://www.quut.com/gsm/gsm-1.0.13.tar.gz
  tar -xvzf gsm-1.0.13.tar.gz
  cd gsm-1.0-pl13 && make && make install
  cp -rf ./inc/* /usr/local/include
  cp -rf ./lib/* /usr/local/lib

  git clone https://github.com/DoubangoTelecom/g729.git
  cd g729
  ./autogen.sh && ./configure --enable-static --disable-shared && make && make install
  
  
  cd /home/cxl/nodejs/projects/sip/doubango/thirdparties/scripts/ilbc
  wget http://www.ietf.org/rfc/rfc3951.txt
  awk -f extract.awk rfc3951.txt
  ./autogen.sh && ./configure
  make && make install

```

#  build "Doubango IMS Framework v2.0"
