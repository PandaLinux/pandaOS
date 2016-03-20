#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gcc"
PKG_VERSION="5.3.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function prepare() {
    ln -sv "../../source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    mkdir "${BUILD_DIR}" &&
    cd "${BUILD_DIR}" &&
    ../libstdc++-v3/configure --target="$TARGET"              \
			      --prefix=/tools                 \
			      --disable-multilib              \
			      --disable-nls                   \
			      --disable-libstdcxx-threads     \
			      --disable-libstdcxx-pch         \
			      --with-gxx-include-dir=/tools/$TARGET/include/c++/$PKG_VERSION
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
