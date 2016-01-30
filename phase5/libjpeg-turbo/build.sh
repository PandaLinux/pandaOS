#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="libjpeg-turbo"
PKG_VERSION="1.4.2"

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
	sed -i -e '/^docdir/ s:$:/libjpeg-turbo-1.4.2:' Makefile.in &&

	./configure --prefix=/usr           \
    	        --mandir=/usr/share/man \
    	        --with-jpeg8            \
    	        --disable-static &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL test
}

function instal() {
	make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
