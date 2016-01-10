#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="libcap"
PKG_VERSION="2.24"

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
    sed -i '/install.*STALIBNAME/d' libcap/Makefile      
    make $MAKE_PARALLEL
}

function check() {
    echo "Nothing to be done here."
}

function instal() {
    make $MAKE_PARALLEL RAISE_SETFCAP=no prefix=/usr install
    chmod -v 755 /usr/lib/libcap.so
    
    mv -v /usr/lib/libcap.so.* /lib
    ln -sfv ../../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean