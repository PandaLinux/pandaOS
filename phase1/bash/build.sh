#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="bash"
PKG_VERSION="4.3.30"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "../../source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    ./configure --prefix=/tools --without-bash-malloc
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL tests
}

function instal() {
    make $MAKE_PARALLEL install
    ln -sv bash /tools/bin/sh
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
