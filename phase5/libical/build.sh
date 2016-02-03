#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="libical"
PKG_VERSION="1.0.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	mkdir build &&
	cd build &&

	cmake -DCMAKE_INSTALL_PREFIX=/usr \
    	  -DCMAKE_BUILD_TYPE=Release  \
    	  -DSHARED_ONLY=yes           \
    	  .. &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL test
}

function instal() {
	make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
