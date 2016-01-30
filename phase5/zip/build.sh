#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="zip"
PKG_VERSION="30"

TARBALL="${PKG_NAME}${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}${PKG_VERSION}"

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
	make $MAKE_PARALLEL -f unix/Makefile generic_gcc
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL prefix=/usr MANDIR=/usr/share/man/man1 -f unix/Makefile install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
