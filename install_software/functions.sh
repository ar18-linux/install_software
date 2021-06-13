#!/bin/bash


function install_libunique() {
  rm -rf /tmp/build 
  mkdir /tmp/build
  cd /tmp/build
  wget https://download.gnome.org/sources/libunique/1.1/libunique-1.1.6.tar.bz2
  wget https://www.linuxfromscratch.org/patches/blfs/svn/libunique-1.1.6-upstream_fixes-1.patch

  bzip2 -dk libunique-1.1.6.tar.bz2
  tar -xvf libunique-1.1.6.tar

  cd libunique-1.1.6
  patch -Np1 -i ../libunique-1.1.6-upstream_fixes-1.patch &&
  autoreconf -fi &&

  ./configure --prefix=/usr  \
            --disable-dbus \
            --disable-static &&
  LD_PRELOAD= make

  echo "${foo}" | sudo -Sk make install
  echo "${foo}" | sudo -Sk mv /usr/lib/libunique-1.0.so /usr/lib/libunique-1.1.6.so
}


function install_libunique2() {
  rm -rf /tmp/build 
  mkdir /tmp/build
  cd /tmp/build
  wget https://archive.archlinux.org/packages/l/libunique/libunique-1.1.6-8-x86_64.pkg.tar.zst
  echo "${ar18_sudo_password}" | sudo -Sk pacman -U --noconfirm libunique-1.1.6-8-x86_64.pkg.tar.zst
}
