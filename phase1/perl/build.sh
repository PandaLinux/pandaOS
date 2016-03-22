#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="perl"
PKG_VERSION="5.22.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "../../source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    sh Configure -des -Dprefix=/tools -Dlibs=-lm
    make $MAKE_PARALLEL
}

function check() {
    echo " "
}

function instal() {
    cp -v perl cpan/podlators/pod2man /tools/bin
    mkdir -pv /tools/lib/perl5/$PKG_VERSION
    cp -Rv lib/* /tools/lib/perl5/$PKG_VERSION
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
