#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="readline"
PKG_VERSION="6.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../$PKG_NAME-$PKG_VERSION-upstream_fixes-3.patch
    
    sed -i '/MV.*old/d' Makefile.in
    sed -i '/{OLDSUFF}/c:' support/shlib-install
    
    ./configure 	 \
	--prefix=/usr 	 \
	--disable-static
    make $MAKE_PARALLEL SHLIB_LIBS=-lncurses
}

function check() {
    echo " "
}

function instal() {
    make $MAKE_PARALLEL SHLIB_LIBS=-lncurses install
    
    mv -v /usr/lib/lib{readline,history}.so.* /lib
    ln -sfv ../../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
    ln -sfv ../../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
