#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="perl"
PKG_VERSION="5.22.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

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
    sh Configure -des -Dprefix=/tools -Dlibs=-lm
    make $MAKE_PARALLEL
}

function check() {
    echo 'No tests are available.'
}

function instal() {
    cp -v perl cpan/podlators/pod2man /tools/bin
    mkdir -pv /tools/lib/perl5/5.22.0
    cp -Rv lib/* /tools/lib/perl5/5.22.0
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
