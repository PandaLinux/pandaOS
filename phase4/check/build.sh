#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="check"
PKG_VERSION="0.10.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
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
	./configure --prefix=/usr --disable-static &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL -k check
}

function instal() {
	make $MAKE_PARALLEL docdir=/usr/share/doc/${PKG_NAME}-${PKG_VERSION} install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
