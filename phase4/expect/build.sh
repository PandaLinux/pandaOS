#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="expect"
PKG_VERSION="5.45"

TARBALL="${PKG_NAME}${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr           \
    	        --with-tcl=/usr/lib     \
    	        --enable-shared         \
    	        --mandir=/usr/share/man \
    	        --with-tclinclude=/usr/include &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL test
}

function instal() {
	make $MAKE_PARALLEL install &&
	ln -svf ${PKG_NAME}${PKG_VERSION}/lib${PKG_NAME}${PKG_VERSION}.so /usr/lib
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
