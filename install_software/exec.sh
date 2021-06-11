#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

. "${script_dir}/vars"

set -e

read -s -p "foo:" foo

function aur() {
  name="$1"
  rm -rf /tmp/build 
  mkdir /tmp/build
  cd /tmp/build
  git clone https://aur.archlinux.org/${name}.git
  cd /tmp/build/${name}
  set +e
  LD_PRELOAD= makepkg -m --noconfirm
  if [ "$?" != "0" ]; then
    out="$(LD_PRELOAD= makepkg -m --noconfirm)"
    echo "${out}" | grep "Missing dependencies"
    if [ "$?" = "0" ]; then
      out="$(echo "${out}" | grep '\->')"
      declare -a arr
      arr=($(echo ${out}))
      for item in "${arr[@]}"; do
        if [ "${item}" != "->" ] && [ "${item}" != "" ]; then
          clean="$(echo "${item}" | sed -e 's/>=.*//g')"
          echo "${foo}" | sudo -S -k pacman -Sy --noconfirm "${clean}"
        fi
      done
    fi
    LD_PRELOAD= makepkg --noconfirm
  fi
  set -e
  echo "${foo}" | sudo -S -k pacman -U --noconfirm --asdep ./*zst
}


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
  echo "${foo}" | sudo -Sk pacman -U --noconfirm libunique-1.1.6-8-x86_64.pkg.tar.zst
}


if [ "${debug}" = "0" ]; then
  echo "${foo}" | sudo -S -k pacman -Syy
fi

echo "${foo}" | sudo -S -k pacman -Su --noconfirm

echo "${foo}" | sudo -S -k pacman -Sy --noconfirm \
  spacefm bitwarden firefox thunderbird clementine git expect base-devel postgresql copyq vlc\
  xfce4-cpugraph-plugin qbittorrent ksysguard xterm lsof psi

echo "${foo}" | sudo -S -k usermod -u 5432 postgres
echo "${foo}" | sudo -S -k groupmod -g 5432 postgres

install_libunique2

aur "alarm-clock-applet"
aur fsearch-git
aur masterpdfeditor
aur google-chrome
aur hstr

set +x
