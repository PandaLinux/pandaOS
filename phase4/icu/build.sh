#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="icu"
PKG_VERSION="4c-56_1"

TARBALL="${PKG_NAME}${PKG_VERSION}-src.tgz"
SRC_DIR="${PKG_NAME}"

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
}

clean;prepare;unpack;pushd ${SRC_DIR}/source;build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean