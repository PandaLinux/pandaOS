#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="mozjs"
PKG_VERSION="17.0.0"

TARBALL="${PKG_NAME}${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    cd js/src &&

	sed -i 's/(defined\((@TEMPLATE_FILE)\))/\1/' config/milestone.pl &&

	./configure --prefix=/usr       \
    	        --enable-readline   \
    	        --enable-threadsafe \
    	        --with-system-ffi   \
    	        --with-system-nspr &&
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install &&

	find /usr/include/js-17.0/            \
    	 /usr/lib/libmozjs-17.0.a         \
    	 /usr/lib/pkgconfig/mozjs-17.0.pc \
    	 -type f -exec chmod -v 644 {} \;
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
