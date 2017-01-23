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

# 原文technical guide 1.0
```
This section explains how to build the project using CentOS 64 but could be easily adapted for Linux, Windows or OS X.
webrtc2sip gateway depends on Doubango IMS Framework v2.0.
1.	Preparing the system
sudo yum update
sudo yum install make libtool autoconf subversion git cvs wget libogg-devel gcc gcc-c++ pkgconfig
5.1	Building Doubango IMS Framework
Doubango is an IMS framework and contains all signaling protocols (SIP, SDP, WebSocket…) and media engine (RTP stack, audio/video codecs…) required by webrtc2sip gateway.
The first step is to checkout Doubango 2.0 source code:
svn checkout http://doubango.googlecode.com/svn/branches/2.0/doubango doubango

1.	Building libsrtp
  libsrtp is required.
  git clone https://github.com/cisco/libsrtp/
  cd libsrtp
  CFLAGS="-fPIC" ./configure --enable-pic && make && make install
  
2.	Building OpenSSL
OpenSSL is required if you want to use the RTCWeb Brapteaker module or Secure WebSocket transport (WSS). OpenSSL version 1.0.1 is required if you want support for DTLS-SRTP.
This section is only required if you don’t have OpenSSL installed on your system or using version prior to 1.0.1 and want to enable DTLS-SRTP. 
A quick way to have OpenSSL may be installing openssl-devel package but this version will most likely be outdated (prior to 1.0.1). Anyway, you can check the version like this: openssl version.
wget http://www.openssl.org/source/openssl-1.0.1c.tar.gz
tar -xvzf openssl-1.0.1c.tar.gz
cd openssl-1.0.1c
./config shared --prefix=/usr/local --openssldir=/usr/local/openssl && make && make install

3.	Building libspeex and libspeexdsp
libspeex (audio codec) is optional and libspeexdsp (audio processing and jitter buffer) is required. 
You can install the devel packages:
yum install speex-devel
Or build the source by yourself:
wget http://downloads.xiph.org/releases/speex/speex-1.2beta3.tar.gz
tar -xvzf speex-1.2beta3.tar.gz
cd speex-1.2beta3
./configure --disable-oggtest --without-libogg && make && make install

4.	Building YASM
YASM is only required if you want to enable VPX (VP8 video codec) or x264 (H.264 codec). 
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar -xvzf yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure && make && make install
5.	Building libvpx
Date: December 1, 2012.
libvpx adds support for VP8 and is optional but highly recommended if you want support for video when using Google Chrome or Mozilla Firefox.
You can install the devel packages:
sudo yum install libvpx-devel
Or build the source by yourself:
git clone http://git.chromium.org/webm/libvpx.git
cd libvpx
./configure --enable-realtime-only --enable-error-concealment --disable-examples --enable-vp8 --enable-pic --enable-shared --as=yasm
make && make install

6.	Building libyuv
libyuv is optional. Adds support for video scaling and chroma conversion.
mkdir libyuv && cd libyuv
svn co http://src.chromium.org/svn/trunk/tools/depot_tools . 
./gclient config http://libyuv.googlecode.com/svn/trunk
./gclient sync && cd trunk
make -j6 V=1 -r libyuv BUILDTYPE=Release
make -j6 V=1 -r libjpeg BUILDTYPE=Release
cp out/Release/obj.target/libyuv.a /usr/local/lib
cp out/Release/obj.target/third_party/libjpeg_turbo/libjpeg_turbo.a /usr/local/lib
mkdir --parents /usr/local/include/libyuv/libyuv
cp -rf include/libyuv.h /usr/local/include/libyuv
cp -rf include/libyuv/*.h /usr/local/include/libyuv/libyuv

7.	Building opencore-amr
opencore-amr is optional. Adds support for AMR audio codec.
git clone git://opencore-amr.git.sourceforge.net/gitroot/opencore-amr/opencore-amr
autoreconf --install && ./configure && make && make install

8.	Build libopus
libopus is optional but highly recommended as it’s an MTI codec for WebRTC. Adds support for Opus audio codec.
wget http://downloads.xiph.org/releases/opus/opus-1.0.2.tar.gz
tar -xvzf opus-1.0.2.tar.gz
cd opus-1.0.2
./configure --with-pic --enable-float-approx && make && make install

9.	Building libgsm
libgsm is optional. Adds support for GSM audio codec.
You can install the devel packages (recommended):
sudo yum install gsm-devel
Or build the source by yourself:
wget http://www.quut.com/gsm/gsm-1.0.13.tar.gz
tar -xvzf gsm-1.0.13.tar.gz
cd gsm-1.0-pl13 && make && make install
#cp -rf ./inc/* /usr/local/include
#cp -rf ./lib/* /usr/local/lib

10.	Building g729
G729 is optional. Adds support for G.729 audio codec.
svn co http://g729.googlecode.com/svn/trunk/ g729b
cd g729b
./autogen.sh && ./configure --enable-static --disable-shared && make && make install

11.	Building iLBC
iLBC is optional. Adds support for iLBC audio codec.

svn co http://doubango.googlecode.com/svn/branches/2.0/doubango/thirdparties/scripts/ilbc
cd ilbc
wget http://www.ietf.org/rfc/rfc3951.txt
awk -f extract.awk rfc3951.txt
./autogen.sh && ./configure
make && make install

12.	Building x264
Date: December 2, 2012
x264 is optional and adds support for H.264 video codec (requires FFmpeg).
wget ftp://ftp.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
tar -xvjf last_x264.tar.bz2
# the output directory may be difference depending on the version and date
cd x264-snapshot-20121201-2245
./configure --enable-shared --enable-pic && make && make install

13.	Building FFmpeg
Date: December 2, 2012
FFmpeg is optional and adds support for H.263, H.264 (requires x264) and MP4V-ES video codecs.
git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
cd ffmpeg

# grap a release branch
git checkout n1.2

# configure source code
./configure \
--extra-cflags="-fPIC" \
--extra-ldflags="-lpthread" \
\
--enable-pic --enable-memalign-hack --enable-pthreads \
--enable-shared --disable-static \
--disable-network --enable-pthreads \
--disable-ffmpeg --disable-ffplay --disable-ffserver --disable-ffprobe \
\
--enable-gpl \
\
--disable-debug

make && make install

14.	Building Doubango
Minimal build
cd doubango && ./autogen.sh && ./configure --with-ssl --with-srtp --with-speexdsp
make && make install
Recommended build
cd doubango && ./autogen.sh && ./configure --with-ssl --with-srtp --with-speexdsp --with-ffmpeg
make && make install
Full build
cd doubango && ./autogen.sh && ./configure --with-ssl --with-srtp --with-vpx --with-yuv --with-amr --with-speex --with-speexdsp --with-gsm --with-ilbc --with-g729 --with-ffmpeg
make && make install
5.2	Building webrtc2sip
webrtc2sip depends on Doubango IMS Framework v2.0 and libxml2.
The first step is to checkout the source code:
svn co http://webrtc2sip.googlecode.com/svn/trunk/ webrtc2sip

3.	Installing libxml2
yum install libxml2-devel

4.	Building webrtc2sip
export PREFIX=/opt/webrtc2sip
cd webrtc2sip && ./autogen.sh && ./configure --prefix=$PREFIX
make clean && make && make install
cp -f ./config.xml $PREFIX/sbin/config.xml
```

# 服务器准备
```
* apt-get update
* root@1604developer:/etc/apt# git --version
  git version 2.7.4
* root@1604developer:/etc/apt# wget --version
  GNU Wget 1.17.1 built on linux-gnu
* apt install make
  root@1604developer:/etc/apt# make --version
  GNU Make 4.1
* apt-get install libtool
  root@1604developer:~# libtoolize --version
  libtoolize (GNU libtool) 2.4.6
* apt-get install autoconf
  root@1604developer:/etc/apt# autoconf --version
  autoconf (GNU Autoconf) 2.69
* apt-get install subversion
  root@1604developer:/etc/apt# svn --version
  svn, version 1.9.3 (r1718519)
* apt-get install cvs
  root@1604developer:/etc/apt# cvs --version
  Concurrent Versions System (CVS) 1.12.13-MirDebian-11 (client/server)
* apt-get install libogg-dev
  root@1604developer:/etc/apt# apt-cache show libogg-dev | grep "^Version"
  Version: 1.3.2-1
* root@1604developer:/etc/apt# gcc --version
  gcc (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609
* apt install g++
  root@1604developer:/etc/apt# g++ --version
  g++ (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609
* apt install pkg-config
  root@1604developer:/etc/apt# pkg-config --version
  0.29.1
```
# 安装doubango框架
```
* git clone https://github.com/DoubangoTelecom/doubango.git
* git clone https://github.com/cisco/libsrtp/
  cd libsrtp
  CFLAGS="-fPIC" ./configure --enable-pic && make && make install
  apt-cache search /usr/share/dict*
  apt-get install wbritish
  make runtest
  git pull 
  git checkout v1.5.4
  make clean
  CFLAGS="-fPIC" ./configure --enable-pic && make && make install
  
* root@1604developer:/home/cxl/sip/depend/libsrtp# openssl version -a
  OpenSSL 1.0.2g  1 Mar 2016
  wget http://www.openssl.org/source/openssl-1.0.1c.tar.gz
  tar -xvzf openssl-1.0.1c.tar.gz
  cd openssl-1.0.1c
  ./config shared --prefix=/usr/local --openssldir=/usr/local/openssl && make && make install

  
  
* wget http://downloads.xiph.org/releases/speex/speex-1.2beta3.tar.gz
  tar -xvzf speex-1.2beta3.tar.gz
  cd speex-1.2beta3
  ./configure --disable-oggtest --without-libogg && make && make install
  
  find /usr -name libspeex.so.1
  root@1604developer:/home/cxl/sip/depend/speex-1.2beta3# speexenc --version
  speexenc (Speex encoder) version 1.2beta3 (compiled Jan 20 2017)
* wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
  tar -xvzf yasm-1.2.0.tar.gz
  cd yasm-1.2.0
  ./configure && make && make install
  root@1604developer:/home/cxl/sip/depend/yasm-1.2.0# yasm --version
  yasm 1.2.0

* git clone https://chromium.googlesource.com/webm/libvpx
  cd libvpx
  ./configure --enable-realtime-only --enable-error-concealment --disable-examples --enable-vp8 --enable-pic --enable-shared --as=yasm
  make && make install
  ls  /usr/local/lib/libvpx.so

* mkdir libyuv && cd libyuv
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
  git clone https://chromium.googlesource.com/libyuv/libyuv
  https://chromium.googlesource.com/libyuv/libyuv/+/master/docs/getting_started.md
  apt-get install clang-3.8
  apt install clang
  make V=1 -f linux.mk
  make V=1 -f linux.mk clean
  make V=1 -f linux.mk CXX=clang++
  apt-get install cmake
  
  mkdir out
  cd out
  cmake ..
  cmake --build .
  
  mkdir out
  cd out
  cmake -DCMAKE_INSTALL_PREFIX="/usr/lib" -DCMAKE_BUILD_TYPE="Release" ..
  cmake --build . --config Release
  sudo cmake --build . --target install --config Release
  
  cp libyuv.a /usr/local/lib/libyuv.a
  cp include/* /usr/local/include/libyuv/ -rf
  git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git
  cd libjpeg-turbo
  autoreconf -fiv
  mkdir out && cd out
  ../configure
  make
  cp .libs/libjpeg.a /usr/local/lib/libjpeg.a
  cd /usr/local/lib
  ln -s libjpeg.a libjpeg_turbo.a
* git clone git://opencore-amr.git.sourceforge.net/gitroot/opencore-amr/opencore-amr
  cd opencore-amr && autoreconf --install && ./configure && make && make install
* wget http://downloads.xiph.org/releases/opus/opus-1.0.2.tar.gz
  tar -xvzf opus-1.0.2.tar.gz
  cd opus-1.0.2
  ./configure --with-pic --enable-float-approx && make && make install
* wget http://www.quut.com/gsm/gsm-1.0.13.tar.gz
  tar -xvzf gsm-1.0.13.tar.gz
  cd gsm-1.0-pl13 && make && make install
  #cp -rf ./inc/* /usr/local/include
  #cp -rf ./lib/* /usr/local/lib
* git clone https://github.com/DoubangoTelecom/g729.git
  cd g729
  ./autogen.sh && ./configure --enable-static --disable-shared && make && make install

* cd doubango/thirdparties/scripts/ilbc
  wget http://www.ietf.org/rfc/rfc3951.txt
  wget http://www.ietf.org/rfc/rfc3951.txt
  awk -f extract.awk rfc3951.txt
  vi autogen.sh
  set ff=unix
  wq
  ./autogen.sh && ./configure
  make && make install
* wget ftp://ftp.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
  tar -xvjf last_x264.tar.bz2
  cd x264-snapshot-20170121-2245/
  ./configure --enable-shared --enable-pic && make && make install

* git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
  git clone https://github.com/FFmpeg/FFmpeg.git 
  cd Ffmpeg
  git checkout n1.2
  ./configure --extra-cflags="-fPIC" --extra-ldflags="-lpthread" --enable-pic --enable-memalign-hack --enable-pthreads --enable-shared --disable-static --disable-network --enable-pthreads --disable-ffmpeg --disable-ffplay --disable-ffserver --disable-ffprobe --enable-gpl --disable-debug
  make && make install
  
*  cd doubango && ./autogen.sh && ./configure --with-ssl --with-srtp --with-speexdsp
   make && make install

* 
```
