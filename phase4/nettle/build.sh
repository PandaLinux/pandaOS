#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="nettle"
PKG_VERSION="3.1.1"

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
    ./configure --prefix=/usr &&
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_CHECK check
}

function instal() {
    sed -i '/^install-here/ s/ install-static//' Makefile
    make $MAKE_PARALLEL install 					&&
    chmod   -v   755 /usr/lib/lib{hogweed,nettle}.so 			&&
    install -v -m755 -d /usr/share/doc/${PKG_NAME}-${PKG_VERSION}  	&&
    install -v -m644 nettle.html /usr/share/doc/${PKG_NAME}-${PKG_VERSION}
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean