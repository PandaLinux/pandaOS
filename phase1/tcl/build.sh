#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="tcl"
PKG_VERSION="8.6.4"

TARBALL="${PKG_NAME}-core${PKG_VERSION}-src.tar.gz"
SRC_DIR="${PKG_NAME}${PKG_VERSION}"

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
    cd unix &&
    ./configure --prefix=/tools
    make $MAKE_PARALLEL
    TZ=UTC make $MAKE_PARALLEL test
    make $MAKE_PARALLEL install
    chmod -v u+w /tools/lib/libtcl8.6.so
    make $MAKE_PARALLEL install-private-headers
    ln -sv tclsh8.6 /tools/bin/tclsh
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;popd;clean
