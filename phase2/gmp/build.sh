#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="gmp"
PKG_VERSION="6.0.0a"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-6.0.0"

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
	--enable-cxx	 \
	--disable-static \
	--docdir=/usr/share/doc/gmp-6.0.0a
    make $MAKE_PARALLEL
    make $MAKE_PARALLEL html
}

function check() {
    make $MAKE_PARALLEL check 2>&1 | tee gmp-check-log
    awk '/tests passed/{total+=$2} ; END{print total}' gmp-check-log
}

function instal() {
    make $MAKE_PARALLEL install
    make $MAKE_PARALLEL install-html
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean