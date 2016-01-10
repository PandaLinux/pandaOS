#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="libpng"
PKG_VERSION="1.6.19"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
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
    patch -Np1 -i ../libpng-1.6.19-apng.patch
    ./configure --prefix=/usr --disable-static &&
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install &&
    mkdir -v "/usr/share/doc/$PKG_NAME-$PKG_VERSION" &&
    cp -v README libpng-manual.txt "/usr/share/doc/$PKG_NAME-$PKG_VERSION"
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean