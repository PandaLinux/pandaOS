#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="libevent"
PKG_VERSION="2.0.22"

TARBALL="${PKG_NAME}-${PKG_VERSION}-stable.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}-stable"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "/source/$TARBALL" "$TARBALL"
    fi
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr --disable-static &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install		
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
