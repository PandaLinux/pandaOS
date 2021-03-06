#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="shared-mime-info"
PKG_VERSION="1.4"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr &&
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
