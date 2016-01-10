#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="binutils"
PKG_VERSION="2.25.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

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
    mkdir "${BUILD_DIR}" &&
    cd "${BUILD_DIR}" &&
    CC=$TARGET-gcc             \
    AR=$TARGET-ar              \
    RANLIB=$TARGET-ranlib      \
    ../configure               \
    --prefix=/tools            \
    --disable-nls              \
    --disable-werror           \
    --with-lib-path=/tools/lib \
    --with-sysroot
    make $MAKE_PARALLEL
    make $MAKE_PARALLEL install
    
    make $MAKE_PARALLEL -C ld clean
    make $MAKE_PARALLEL -C ld LIB_PATH=/usr/lib:/lib
    cp -v ld/ld-new /tools/bin
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;popd;clean;