#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="binutils"
PKG_VERSION="2.26"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../$PKG_NAME-$PKG_VERSION-upstream_fix-2.patch

    mkdir "${BUILD_DIR}" &&
    cd "${BUILD_DIR}" &&
    ../configure --prefix=/usr   \
				 --enable-shared \
				 --disable-werror
    make $MAKE_PARALLEL tooldir=/usr
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL tooldir=/usr install
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
