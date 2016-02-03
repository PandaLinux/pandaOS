#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="readline"
PKG_VERSION="6.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "/source/$TARBALL" "$TARBALL"
    fi
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../readline-6.3-upstream_fixes-3.patch
    
    sed -i '/MV.*old/d' Makefile.in
    sed -i '/{OLDSUFF}/c:' support/shlib-install
    
    ./configure 	 \
	--prefix=/usr 	 \
	--disable-static
    make $MAKE_PARALLEL SHLIB_LIBS=-lncurses
}

function check() {
    echo "Nothing to be done here."
}

function instal() {
    make $MAKE_PARALLEL SHLIB_LIBS=-lncurses install
    
    mv -v /usr/lib/lib{readline,history}.so.* /lib
    ln -sfv ../../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
    ln -sfv ../../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
