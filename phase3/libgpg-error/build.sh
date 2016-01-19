#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="libgpg-error"
PKG_VERSION="1.20"

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
    ./configure --prefix=/usr --disable-static &&
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install &&
	install -v -m644 -D README /usr/share/doc/${PKG_NAME}-${PKG_VERSION}/README
	
	mv -v /usr/lib/libgpg-error.so.* /lib
	ln -sfv ../../../lib/$(readlink /usr/lib/libgpg-error.so) /usr/lib/libgpg-error.so
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
