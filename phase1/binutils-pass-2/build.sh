#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="binutils"
PKG_VERSION="2.26"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function prepare() {
    ln -sv "../../source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    mkdir 	"${BUILD_DIR}" &&
    cd 		"${BUILD_DIR}" &&
    CC=$TARGET-gcc             		    \
    AR=$TARGET-ar              	            \
    RANLIB=$TARGET-ranlib      		    \
    ../configure --prefix=/tools            \
		 --disable-nls              \
		 --disable-werror           \
		 --with-lib-path=/tools/lib \
		 --with-sysroot
    make $MAKE_PARALLEL    
}

function check() {
	echo " "
}

function instal(){
	make $MAKE_PARALLEL install
    
    make $MAKE_PARALLEL -C ld clean
    make $MAKE_PARALLEL -C ld LIB_PATH=/usr/lib:/lib
    cp -v ld/ld-new /tools/bin
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
