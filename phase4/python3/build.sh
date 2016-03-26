#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="Python"
PKG_VERSION="3.5.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	CXX="/usr/bin/g++"              \
	./configure --prefix=/usr       \
	            --enable-shared     \
    	        --with-system-expat \
    	        --with-system-ffi   \
    	        --without-ensurepip &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL clean
	CXX="/usr/bin/g++"              \
	./configure --prefix=/usr       \
	            --enable-shared     \
    	        --with-system-expat \
    	        --with-system-ffi   \
    	        --without-ensurepip \
    	        --with-pydebug		&&
	make $MAKE_PARALLEL				&&
	make $MAKE_PARALLEL test
}

function instal() {
	make $MAKE_PARALLEL install &&
	chmod -v 755 /usr/lib/libpython3.5m.so &&
	chmod -v 755 /usr/lib/libpython3.so
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;instal;[[ $MAKE_CHECK = TRUE ]] && check;popd;clean
