#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="Python"
PKG_VERSION="2.7.11"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr       \
	            --enable-shared     \
    	        --with-system-expat \
    	        --with-system-ffi   \
    	        --enable-unicode=ucs4 &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL -k test
}

function instal() {
	make $MAKE_PARALLEL install &&
	chmod -v 755 /usr/lib/libpython2.7.so.1.0	
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
