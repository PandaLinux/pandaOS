#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="gcc"
PKG_VERSION="5.2.0"

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
    ../libstdc++-v3/configure       \
    --target="$TARGET"              \
    --prefix=/tools                 \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$TARGET/include/c++/5.2.0
     make $MAKE_PARALLEL
     make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;popd;clean
