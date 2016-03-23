#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="openssl"
PKG_VERSION="1.0.2g"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {    
    ./config --prefix=/usr         \
	         --openssldir=/etc/ssl \
    	     --libdir=lib          \
    	     shared                \
    	     zlib-dynamic &&
	make -j1
}

function check() {
	make -j1 test
}

function instal() {
	sed -i 's# libcrypto.a##;s# libssl.a##' Makefile
	make -j1 install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
