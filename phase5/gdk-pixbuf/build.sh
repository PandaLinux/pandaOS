#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="gdk-pixbuf"
PKG_VERSION="2.32.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
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
	./configure --prefix=/usr --with-x11 &&
	make $MAKE_PARALLEL
}

function check() {
	# This package comes with a test suite
	# But the tests are very resource hungary and consumes 
	# a lot of cpu power.
	#
	# make $MAKE_PARALLEL check
	#
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean