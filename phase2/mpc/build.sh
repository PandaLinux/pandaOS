#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="mpc"
PKG_VERSION="1.0.3"

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
      ./configure	 \
	--prefix=/usr    \
	--disable-static \
	--docdir=/usr/share/doc/mpc-1.0.3
    make $MAKE_PARALLEL
    make $MAKE_PARALLEL html
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install
    make $MAKE_PARALLEL install-html
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean