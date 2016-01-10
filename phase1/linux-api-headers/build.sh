#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="linux"
PKG_VERSION="4.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
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
    make $MAKE_PARALLEL mrproper
    make $MAKE_PARALLEL INSTALL_HDR_PATH=dest headers_install
    cp -rv dest/include/* /tools/include
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;popd;clean
