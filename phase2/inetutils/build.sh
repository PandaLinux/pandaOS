#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="inetutils"
PKG_VERSION="1.9.4"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {    
    ./configure --prefix=/usr 	     \
				--localstatedir=/var \
				--disable-logger     \
				--disable-whois      \
				--disable-rcp        \
				--disable-rexec      \
				--disable-rlogin     \
				--disable-rsh        \
				--disable-servers
    make $MAKE_PARALLEL
}

function check() {
	# This comes packages comes with a test suite.
	# But the tests are not run as it is not mandatory
	#
	# make $MAKE_PARALLEL check
	#
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
