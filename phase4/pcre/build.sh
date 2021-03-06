#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="pcre"
PKG_VERSION="8.38"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr                     \
    	        --enable-unicode-properties       \
    	        --enable-pcre16                   \
    	        --enable-pcre32                   \
    	        --enable-pcregrep-libz            \
    	        --enable-pcregrep-libbz2          \
    	        --enable-pcretest-libreadline     \
    	        --disable-static                 &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL install			&&
	mv -v /usr/lib/libpcre.so.* /lib 	&&
	ln -sfv ../../lib/$(readlink /usr/lib/libpcre.so) /usr/lib/libpcre.so
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
