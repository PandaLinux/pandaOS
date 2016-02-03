#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="curl"
PKG_VERSION="7.45.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.lzma"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {    
    ./configure --prefix=/usr              \
	            --disable-static           \
    	        --enable-threaded-resolver &&
	make $MAKE_PARALLEL    	        
}

function check() {
	make $MAKE_PARALLEL test
}

function instal() {
    make $MAKE_PARALLEL install &&
	find docs \( -name Makefile\* -o -name \*.1 -o -name \*.3 \) -exec rm {} \; &&
	install -v -dm755 /usr/share/doc/curl-7.45.0 &&
	cp -rv docs/*     /usr/share/doc/curl-7.45.0
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
