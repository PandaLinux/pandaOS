#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="ncurses"
PKG_VERSION="6.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "../../source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    sed -i s/mawk// configure
    ./configure --prefix=/tools \
	            --with-shared   \
    	        --without-debug \
    	        --without-ada   \
    	        --enable-widec  \
    	        --enable-overwrite
    make $MAKE_PARALLEL    
}

function check() {
	echo " "
}

function instal(){
	make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
