from http://marcelog.github.io/articles/installing_webrtc2sip_in_amazon_linux_in_aws.html
Compiling and Installing WebRTC2SIP.

What is WebRTC2SIP and how to use it with the Asterisk PBX in the Amazon AWS EC2 service
NOTE: If you are trying or want to get rid of webrtc2sip and use a plain asterisk installation, see "WebRTC with Asterisk and Amazon AWS".
A lot of sources around the Internet explain how to compile and install Webrtc2sip so one can have SIP as the signaling protocol in a webrtc application, mostly in conjunction with Asterisk and/or FreeSWITCH.
Most of the time those instructions are outdated or incomplete, so here is the updated way of installing webrtc2sip and its dependencies, using Amazon Linux in an EC2 instance inside AWS, altough I'm pretty sure this could also be used for any CentOS like OS.
The original instructions for installing webrtc2sip are located here and this article is a "small" update for it. We try to build webrtc2sip and doubango with as many options as possible, so feel free to skip any dependencies (like codecs) that you are sure will be of no use for you.
NOTE:This will end up with an environment with a mixed license style, so you are warned to check if your product or installation or use of these different pieces of software will violate or not each one the licenses. A good starting point is the Licensing page in the Doubango website.
webrtcsip is made by Doubango, so a big thanks for them to make this available to everyone!
Installing Base Packages needed to build WebRTC2SIP
We first need to install some basic packages, to compile webrtc2sip, doubango, and Asterisk, later on.
#!/bin/bash
sudo yum install \
  nginx \
  make \
  libogg-devel \
  libsqlite-devel \
  libxml2-devel \
  libjpeg-devel \
  openssl-devel \
  ncurses-devel \
  libuuid-devel \
  libtool \
  autoconf \
  subversion \
  git \
  cvs \
  wget \
  gcc \
  gcc-c++ \
  pkgconfig \
  nasm \
  patch \
  screen
view rawinstall_requirements.sh hosted with ❤ by GitHub
Nginx is installed so we can serve our own HTML5 application in the same server, but you can skip it if that will not be your case.
In a similar way, GNU Screen is installed becase I still like to use it, so feel free to also skip it or replace it with another thing.
Install DaemonTools so we can start WebRTC2SIP as a service
It is highly recommended that you manage your asterisk and webrtc2sip installations with daemontools. You can find out how to install them in this article titled: Installing DaemonTools in Amazon Linux (or CentOS like OS).

 
Install libsrtp as a shared library
libsrtp is used to provide audio by using SRTP and its mandatory for webrtc communications. We need to install libsrtp as a shared library:
#!/bin/bash
cd /usr/src
git clone https://github.com/cisco/libsrtp/
cd libsrtp
git checkout v1.5.2
CFLAGS="-fPIC" ./configure --enable-pic && make shared_library && make install
view rawbuild_libsrtp.sh hosted with ❤ by GitHub
Install speex
The Speex codec has been superseded by Opus, and it is optional.
#!/bin/bash
cd /usr/src
wget http://downloads.xiph.org/releases/speex/speex-1.2beta3.tar.gz
tar -xvzf speex-1.2beta3.tar.gz
cd speex-1.2beta3
./configure
make
make install
view rawbuild_speex.sh hosted with ❤ by GitHub
Install YASM
If you want codecs like VP8 or H.264, then you will need YASM to build the libraries VPX and x264 respectively.
#!/bin/bash
cd /usr/src
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar -xvzf yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure
make
make install
export PATH=$PATH:/usr/local/bin
view rawbuild_yasm.sh hosted with ❤ by GitHub
Install libvpx (for VP8/9 codecs)
This one is optional but recommended to support video in Chrome or Firefox.
#!/bin/bash
cd /usr/src
git clone https://chromium.googlesource.com/webm/libvpx
cd libvpx
./configure \
  --enable-realtime-only \
  --enable-error-concealment \
  --disable-examples \
  --enable-vp8 \
  --enable-pic \
  --enable-shared \
  --as=yasm
make
make install
view rawbuild_libvpx.sh hosted with ❤ by GitHub
Install libopus
One of the Mandatory to Implement (MTI) audio codecs for WebRTC is Opus.
#!/bin/bash
cd /usr/src
wget http://downloads.xiph.org/releases/opus/opus-1.0.2.tar.gz
tar -xvzf opus-1.0.2.tar.gz
cd opus-1.0.2
./configure --with-pic --enable-float-approx
make
make install
view rawbuild_libopus.sh hosted with ❤ by GitHub
Install opencore-amr
The AMR Codec is optional, but you can support it by installing the opencore-amr library.
#!/bin/bash
cd /usr/src
git clone git://opencore-amr.git.sourceforge.net/gitroot/opencore-amr/opencore-amr
cd opencore-amr
autoreconf --install
./configure
make
make install
view rawbuild_opencoreamr.sh hosted with ❤ by GitHub
Install libgsm
libgsm is optional and you can install it if you want to provide support for the GSM codec.
#!/bin/bash
cd /usr/src
wget http://www.quut.com/gsm/gsm-1.0.13.tar.gz
tar -xvzf gsm-1.0.13.tar.gz
view rawdownload_libgsm.sh hosted with ❤ by GitHub
You have to download and apply the following patch so you can build libgsm as a shared library:
#!/bin/bash
wget https://gist.githubusercontent.com/marcelog/9b5410706640279218ba/raw/017e98f03187ebd12e059f0170f7ca764a81edfa/libgsm-shared.patch
patch -p0 < libgsm-shared.patch
cd gsm-1.0-pl13 && make && make install
ln -s /usr/local/include /usr/local/inc
mkdir -p /usr/local/man/man3
make GSM_INSTALL_ROOT=/usr/local install
cp lib/libgsm.so* /usr/local/lib
view rawbuild_libgsm.sh hosted with ❤ by GitHub
Install G729
g729 is optional, build it and install it to enable support for the G.729 codec.
#!/bin/bash
cd /usr/src
git clone https://github.com/DoubangoTelecom/g729
cd g729
./autogen.sh
./configure --enable-static --disable-shared
make
make install
view rawbuild_g729.sh hosted with ❤ by GitHub
Install iLBC
The iLBC codec is also optional, but you can enable support for it by installing the iLBC library that comes with Doubango:
#!/bin/bash
cd /usr/src
git checkout https://github.com/Distrotech/libilbc-webrtc
cd libilbc-webrtc
./configure
make
make install
view rawbuild_ilbc.sh hosted with ❤ by GitHub
Install x264
The x264 library will provide support for the H.264 codec (also, optional).
#!/bin/bash
cd /usr/src
wget ftp://ftp.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
tar -xvjf last_x264.tar.bz2
cd x264-snapshot-*
./configure --enable-shared --enable-pic
make
make install
view rawbuild_x264.sh hosted with ❤ by GitHub
Install FFMpeg
FFMpeg is required to support (the optional codecs) H.263 codec, H.264 (requires x264), and MP4V-ES.
#!/bin/bash
cd /usr/src
git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
cd ffmpeg
git checkout n1.2
./configure \
  --extra-cflags="-fPIC" \
  --extra-ldflags="-lpthread" \
  --enable-pic \
  --enable-memalign-hack \
  --enable-pthreads \
  --enable-shared \
  --disable-static \
  --disable-network \
  --enable-pthreads \
  --disable-ffmpeg \
  --disable-ffplay \
  --disable-ffserver \
  --disable-ffprobe \
  --enable-gpl \
  --enable-nonfree \
  --disable-debug \
  --enable-libx264 \
  --enable-encoder=libx264 \
  --enable-decoder=h264 \
  --enable-encoder=h263 \
  --enable-encoder=h263p \
  --enable-decoder=h263
make
make install
view rawbuild_ffmpeg.sh hosted with ❤ by GitHub
Install openh264
According to the original instructions, if you want to support the H.264 "constrained baseline video", you will need openh264, the main repo is located at GitHub: https://github.com/cisco/openh264.
#!/bin/bash
cd /usr/src
git clone https://github.com/cisco/openh264.git
cd openh264
git checkout v1.1
make ENABLE64BIT=Yes
make install
view rawbuild_openh264.sh hosted with ❤ by GitHub
Install Doubango
Doubango are the guys behind the Doubango Cross-platform 3GPP IMS/LTE framework for embedded systems and it's needed to support all what webrtc2sip does:
#!/bin/bash
cd /usr/src
git clone https://github.com/DoubangoTelecom/doubango
cd doubango
./autogen.sh
view rawbuild_doubango.sh hosted with ❤ by GitHub
If you are building with g.729 support, open up the file configure and locate the following couple of lines:
/* Override any GCC internal prototype to avoid an error.
   Use char because int might match the return type of a GCC
   builtin and then its argument prototype would still apply.  */
#ifdef __cplusplus
extern "C"
#endif
char Init_Decod_ld8a ();
int
main ()
{
return Init_Decod_ld8a ();
  ;
  return 0;
}
view rawconfigure_g729.c hosted with ❤ by GitHub
Just above the line that reads char Init_Decod_ld8a (); add:
int bad_lsf = 0;
view rawg729_patch.c hosted with ❤ by GitHub
This is needed because the symbol bad_lsf is declared as "extern" in the g729 library. Perhaps this changed later on in the g729 library and the doubango framework was not updated to reflect that. Let's move on now with building and installing the framework.
#!/bin/bash
./configure \
  --with-ssl \
  --with-srtp \
  --with-vpx \
  --with-amr \
  --with-speex \
  --with-speexdsp \
  --with-opus \
  --with-gsm \
  --with-ilbc \
  --with-g729 \
  --with-ffmpeg
make
make install
view rawbuild_webrtc2sip.sh hosted with ❤ by GitHub
Install WebRTC2SIP
Finally, we can build the webrtc2sip tool!
#!/bin/bash
cd /usr/src
git clone https://github.com/DoubangoTelecom/webrtc2sip
export PREFIX=/opt/webrtc2sip
cd webrtc2sip
./autogen.sh
LDFLAGS=-ldl ./configure --prefix=$PREFIX
make
make install
cp -f ./config.xml $PREFIX/sbin/config.xml
view rawinstall_webrtc2sip.sh hosted with ❤ by GitHub
Configuring webrtc2sip
Doubango has written a guide about how to install and configure webrtc2sip, you can find it here: http://webrtc2sip.org/technical-guide-1.0.pdf. Once you're satisfied with your configuration file, you can use the flag --config when starting it to specify the location of your config file.
Make WebRTC2SIP run as a service
To start webrtc2sip when the system boots, you can refer to the article titled Starting WebRTC2SIP as a service without screen or console.
That's it! Start writing cool HTML5 and VoIP enabled applications using WebRTC and the Asterisk PBX
Phew! That was long and tedious, but hopefully effective as well :) You now have your own webrtc2sip installation, clean and shiny to start playing around with webrtc, a fun topic indeed!
