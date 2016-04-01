#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="LMDB"
PKG_VERSION="0.9.18"

TARBALL="${PKG_NAME}_${PKG_VERSION}.tar.gz"
SRC_DIR="lmdb-${PKG_NAME}_${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	cd libraries/liblmdb &&
	make                 &&
	sed -i 's| liblmdb.a||' Makefile
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL prefix=/usr install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
