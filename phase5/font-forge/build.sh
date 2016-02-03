#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="fontforge"
PKG_VERSION="20150824"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr     \
	            --enable-gtk2-use \
    	        --disable-static  &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL install
	
	sed -e '/Exec/ s/fontforge/& -new/' \
	    -i /usr/share/applications/fontforge.desktop
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
