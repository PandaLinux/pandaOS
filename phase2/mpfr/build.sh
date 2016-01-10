#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="mpfr"
PKG_VERSION="3.1.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
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
    patch -Np1 -i ../mpfr-3.1.3-upstream_fixes-1.patch
      ./configure	 \
	--prefix=/usr    \
	--enable-thread-safe \
        --docdir=/usr/share/doc/mpfr-3.1.3
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