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
git checkout release/4.0

# NASM
cd ~/ffmpeg_sources && \
wget https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2 && \
tar xjvf nasm-2.13.03.tar.bz2 && \
cd nasm-2.13.03 && \
./autogen.sh && \
PATH="$HOME/bin:$PATH" ./configure \
--prefix="$INSTALL_DIR/ffmpeg_build" \
--enable-pic \
--enable-shared \
--bindir="$HOME/bin" && \
make -j 8 && \
make install

# YASM
cd ~/ffmpeg_sources && \
sudo apt-get -qq -y install yasm

# libx264
cd ~/ffmpeg_sources && \
sudo apt-get -qq -y install libx264-dev

# libx265
sudo apt-get -qq -y install libx265-dev libnuma-dev

# libvpx
cd ~/ffmpeg_sources && \
sudo apt-get -qq -y install libvpx-dev

# libfdk-aac
sudo apt-get -qq -y install libfdk-aac-dev

# libmp3lame
sudo apt-get -qq -y install libmp3lame-dev

# libopus
sudo apt-get -qq -y install libopus-dev

# libaom
cd ~/ffmpeg_sources && \
git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir aom_build && \
cd aom_build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR/ffmpeg_build" -DENABLE_SHARED=on -DENABLE_STATIC=on -DENABLE_NASM=on ../aom && \
PATH="$HOME/bin:$PATH" make -j 8 && \
make install

# after this I had to change the $INSTALL_DIR/ffmpeg_build/include/x265.h to add #include <stdbool.h>

# patch for latest fdk-aac
cd ~/ffmpeg_sources/FFmpeg && \
wget https://github.com/libav/libav/commit/141c960e21d2860e354f9b90df136184dd00a9a8.patch && \
patch -p1 < 141c960e21d2860e354f9b90df136184dd00a9a8.patch


cd ~/ffmpeg_sources && \
cd FFmpeg && \
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$INSTALL_DIR/ffmpeg_build/lib/pkgconfig:$PKG_CONFIG_PATH" ./configure \
  --prefix="$INSTALL_DIR/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$INSTALL_DIR/ffmpeg_build/include -fPIC" \
  --extra-ldflags="-L$INSTALL_DIR/ffmpeg_build/lib -Wl,-Bsymbolic" \
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

# MySQL
export DEBIAN_FRONTEND=noninteractive
echo mysql-server mysql-server/root_password password password | debconf-set-selections;\
echo mysql-server mysql-server/root_password_again password password | debconf-set-selections;

sudo apt-get -qq -y install \
  mysql-server \
  libmysqlclient-dev

sudo pip install -r requirements.txt

# tesseract
sudo apt-get -y install libtesseract-dev \
  libleptonica-dev

# celery

