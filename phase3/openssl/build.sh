#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="openssl"
PKG_VERSION="1.0.2d"

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
    ./config --prefix=/usr         \
	         --openssldir=/etc/ssl \
    	     --libdir=lib          \
    	     shared                \
    	     zlib-dynamic &&
	make -j1
}

function check() {
	make -j1 test
}

function instal() {
	sed -i 's# libcrypto.a##;s# libssl.a##' Makefile
	make -j1 MANDIR=/usr/share/man MANSUFFIX=ssl install &&
	install -v -dm755 /usr/share/doc/${PKG_NAME}-${PKG_VERSION}  &&
	cp -rfv doc/*     /usr/share/doc/${PKG_NAME}-${PKG_VERSION}
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
