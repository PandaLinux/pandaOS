#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="gtk+"
PKG_VERSION="3.18.6"

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
    ./configure --prefix=/usr             \
	            --sysconfdir=/etc         \
    	        --enable-broadway-backend \
    	        --enable-x11-backend      \
    	        --disable-wayland-backend &&
    make $MAKE_PARALLEL
}

function check() {
	# The tests should be run from within the system.
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
