#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="xcb-util-keysyms"
PKG_VERSION="0.4.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

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
    ./configure $XORG_CONFIG &&
    make $MAKE_PARALLEL
}

function check() {
    LD_LIBRARY_PATH=$XORG_PREFIX/lib make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean