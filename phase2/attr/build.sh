#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="attr"
PKG_VERSION="2.4.47"

TARBALL="${PKG_NAME}-${PKG_VERSION}.src.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
    sed -i -e "/SUBDIRS/s|man2||" man/Makefile
    
    ./configure	--prefix=/usr        	\
				--disable-static
    
    make $MAKE_PARALLEL
}

function check() {
    make -j1 tests root-tests
}

function instal() {
    make $MAKE_PARALLEL install install-dev install-lib
    chmod -v 755 /usr/lib/libattr.so
    
    mv -v /usr/lib/libattr.so.* /lib
    ln -sfv ../../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
