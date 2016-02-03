#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="gdbm"
PKG_VERSION="1.11"

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
    ./configure --prefix=/usr 	 \
				--disable-static \
				--enable-libgdbm-compat
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

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
