#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="libpwquality"
PKG_VERSION="1.3.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr --disable-static &&
	make $MAKE_PARALLEL
}

function check() {
	echo ""
}

function instal() {
	make $MAKE_PARALLEL install		
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
