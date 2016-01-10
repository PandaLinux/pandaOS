#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="xclock"
PKG_VERSION="1.0.7"

TARBALL="${PKG_NAME}-${PKG_VERSION}.bz2"
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
    ./configure $XORG_CONFIG &&
    make $MAKE_PARALLEL
}

function check() {
    echo "Nothing to be done here"
}

function instal() {
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean