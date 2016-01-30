#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="vlc"
PKG_VERSION="2.2.1"

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
	sed "s:< 56:< 57:g" -i configure &&
	./configure --prefix=/usr		\
				--disable-lua		\
				--disable-mad		\
				--disable-avcodec	\
				--disable-swscale	\
				--disable-a52		\
				--disable-alsa		&&				
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL docdir=/usr/share/doc/${PKG_NAME}-${PKG_VERSION} install
	
	update-desktop-database
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
