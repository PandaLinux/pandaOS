#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="check"
PKG_VERSION="0.10.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "../../source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    PKG_CONFIG= ./configure --prefix=/tools
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;check;instal;popd;clean
