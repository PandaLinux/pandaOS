#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="dejagnu"
PKG_VERSION="1.5.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "../../source/$TARBALL" "$TARBALL"
    fi
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    ./configure --prefix=/tools
    make $MAKE_PARALLEL install
    make $MAKE_PARALLEL check
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;popd;clean