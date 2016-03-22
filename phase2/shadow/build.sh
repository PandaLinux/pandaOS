#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="shadow"
PKG_VERSION="4.2.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    sed -i 's/groups$(EXEEXT) //' src/Makefile.in
    find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;

    sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
		   -e 's@/var/spool/mail@/var/mail@' etc/login.defs       
    sed -i 's/1000/999/' etc/useradd

    ./configure --sysconfdir=/etc --with-group-name-max-length=32
    make $MAKE_PARALLEL
}

function check() {
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install
    mv -v /usr/bin/passwd /bin
    
    pwconv
    grpconv
    sed -i 's/yes/no/' /etc/default/useradd
    passwd root
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

function passwd() {
  echo "${1}:temppwd" | chpasswd
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
