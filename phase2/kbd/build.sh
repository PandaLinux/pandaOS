#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="kbd"
PKG_VERSION="2.0.3"

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
    patch -Np1 -i ../kbd-2.0.3-backspace-1.patch
    sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
    
    PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
