#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="cmake"
PKG_VERSION="3.4.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {    
    ./bootstrap --prefix=/usr       \
	            --system-libs       \
    	        --no-system-jsoncpp
	make $MAKE_PARALLEL
}

function check() {
	bin/ctest $MAKE_PARALLEL -O cmake-test.log
}

function instal() {
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
