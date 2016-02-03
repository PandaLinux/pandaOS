#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="perl"
PKG_VERSION="5.22.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {    
    echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
    export BUILD_ZLIB=False
    export BUILD_BZIP2=0
    sh Configure -des -Dprefix=/usr            \
                 -Dvendorprefix=/usr           \
                 -Dpager="/usr/bin/less -isR"  \
                 -Duseshrplib
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL -k test
}

function instal() {
    make $MAKE_PARALLEL install
    unset BUILD_ZLIB BUILD_BZIP2
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
