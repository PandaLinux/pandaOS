#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="json-c"
PKG_VERSION="0.12"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	sed -i s/-Werror// Makefile.in             &&
	./configure --prefix=/usr --disable-static &&
	make -j1
}

function check() {
	make -j1 check
}

function instal() {
	make -j1 install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
