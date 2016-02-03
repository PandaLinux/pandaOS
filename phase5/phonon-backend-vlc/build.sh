#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="phonon-backend-vlc"
PKG_VERSION="0.8.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	mkdir build &&
	cd    build &&

	cmake -DCMAKE_INSTALL_PREFIX=/usr    \
    	  -DCMAKE_BUILD_TYPE=Release     \
    	  -DCMAKE_INSTALL_LIBDIR=lib     \
    	  -DPHONON_BUILD_PHONON4QT5=ON   \
    	  -D__KDE_HAVE_GCC_VISIBILITY=NO \
    	  -Wno-dev .. &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install		
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
