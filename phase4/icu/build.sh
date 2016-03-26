#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="icu"
PKG_VERSION="4c-56_1"

TARBALL="${PKG_NAME}${PKG_VERSION}-src.tgz"
SRC_DIR="${PKG_NAME}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	cd source
    ./configure --prefix=/usr 		\
				--sysconfdir=/etc 	\
				--sbindir=/usr/bin 	\
				--enable-static
	make -j1
}

function check() {
    make -j1 -k check
}

function instal() {
    make -j1 install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
