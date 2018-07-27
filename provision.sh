#!/usr/bin/env bash
set -ev

INSTALL_DIR="/home/vagrant"

# some libraries are installed invidually due to dependencies
apt-get -qq update
apt-get -qq -y install autoconf-archive
apt-get -qq -y install libpng12-dev
apt-get -qq -y install libjpeg8-dev
apt-get -qq -y install zlib1g-dev
apt-get -qq -y install libicu-dev
apt-get -qq -y install libpango1.0-dev
apt-get -qq -y install libcairo2-dev
apt-get -qq -y install gcc
apt-get -qq -y install git
apt-get -qq -y install git-core

apt-get -qq -y install libjpeg62-dev
apt-get -qq -u install checkinstall
apt-get -qq -y install zsh


sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

chsh -s `which zsh`


# some libraries are installed invidually due to dependencies
sudo apt-get update -qq && sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  pkg-config \
  texinfo \
  wget \
  python-dev \
  zlib1g-dev

mkdir -p ~/ffmpeg_sources
cd ~/ffmpeg_sources
git clone https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg/
git checkout release/3.4

# NASM
cd ~/ffmpeg_sources && \
wget https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2 && \
tar xjvf nasm-2.13.03.tar.bz2 && \
cd nasm-2.13.03 && \
./autogen.sh && \
PATH="$HOME/bin:$PATH" ./configure \
--prefix="$HOME/ffmpeg_build" \
--enable-pic \
--enable-shared \
--bindir="$HOME/bin" && \
make && \
make install

# YASM
cd ~/ffmpeg_sources && \
wget -O yasm-1.3.0.tar.gz https://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz && \
tar xzvf yasm-1.3.0.tar.gz && \
cd yasm-1.3.0 && \
./configure \
--prefix="$HOME/ffmpeg_build" \
--enable-pic \
--enable-shared \
--bindir="$HOME/bin" && \
make && \
make install

# libx264
cd ~/ffmpeg_sources && \
git -C x264 pull 2> /dev/null || git clone --depth 1 https://git.videolan.org/git/x264 && \
cd x264 && \
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
--prefix="$HOME/ffmpeg_build" \
--bindir="$HOME/bin" \
--enable-static \
--extra-cflags="-fPIC" \
--enable-pic \
--enable-shared && \
PATH="$HOME/bin:$PATH" make && \
make install

# libx265
sudo apt-get -qq -y install mercurial libnuma-dev && \
cd ~/ffmpeg_sources && \
if cd x265 2> /dev/null; then hg pull && hg update; else hg clone https://bitbucket.org/multicoreware/x265; fi && \
cd x265/build/linux && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=on -DENABLE_STATIC=on ../../source && \
PATH="$HOME/bin:$PATH" make && \
make install

# libvpx
cd ~/ffmpeg_sources && \
git -C libvpx pull 2> /dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && \
cd libvpx && \
PATH="$HOME/bin:$PATH" ./configure \
--prefix="$HOME/ffmpeg_build" \
--disable-examples \
--disable-unit-tests \
--extra-cflags="-fPIC" \
--enable-pic \
--enable-shared \
--enable-vp9-highbitdepth \
--as=yasm && \
PATH="$HOME/bin:$PATH" make && \
make install

# libfdk-aac
cd ~/ffmpeg_sources && \
git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac && \
cd fdk-aac && \
autoreconf -fiv && \
./configure \
--prefix="$HOME/ffmpeg_build" \
--with-pic \
--enable-pic \
--enable-shared && \
make && \
make install

# libmp3lame
cd ~/ffmpeg_sources && \
wget -O lame-3.100.tar.gz https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz && \
tar xzvf lame-3.100.tar.gz && \
cd lame-3.100 && \
PATH="$HOME/bin:$PATH" ./configure \
--prefix="$HOME/ffmpeg_build" \
--bindir="$HOME/bin" \
--disable-shared \
--enable-pic \
--enable-shared \
--enable-nasm && \
PATH="$HOME/bin:$PATH" make && \
make install

# libopus
cd ~/ffmpeg_sources && \
git -C opus pull 2> /dev/null || git clone --depth 1 https://github.com/xiph/opus.git && \
cd opus && \
./autogen.sh && \
./configure \
--with-pic \
--prefix="$HOME/ffmpeg_build" \
--enable-pic \
--enable-shared && \
make && \
make install

# libaom
cd ~/ffmpeg_sources && \
git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir aom_build && \
cd aom_build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=on -DENABLE_STATIC=on -DENABLE_NASM=on ../aom && \
PATH="$HOME/bin:$PATH" make && \
make install

# after this I had to change the $HOME/ffmpeg_build/include/x265.h to add #include <stdbool.h>

cd ~/ffmpeg_sources && \
cd FFmpeg && \
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig:$PKG_CONFIG_PATH" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include -fPIC" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib -Wl,-Bsymbolic" \
  --extra-libs="-lpthread -lm" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree \
  --enable-pic \
  --enable-shared && \
PATH="$HOME/bin:$PATH" make -j 8 && \
make install && \
hash -r

chown -R vagrant:vagrant $INSTALL_DIR/ffmpeg_build