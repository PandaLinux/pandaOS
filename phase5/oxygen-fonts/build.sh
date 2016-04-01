#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="oxygen-fonts"
PKG_VERSION="5.4.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	mkdir build &&
	cd    build &&

	cmake -DCMAKE_INSTALL_PREFIX=/usr ..
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
