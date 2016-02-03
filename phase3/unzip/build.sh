#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="unzip"
PKG_VERSION="60"

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
	make $MAKE_PARALLEL -f unix/Makefile generic
}

function check() {
    echo " "
}

function instal() {
	make prefix=/usr -f unix/Makefile $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
