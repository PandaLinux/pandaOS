#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="harfbuzz"
PKG_VERSION="1.1.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
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
	./configure --prefix=/usr &&
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
    rm -rf /phase4/freetype/DONE
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean