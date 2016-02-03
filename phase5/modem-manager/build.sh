#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="ModemManager"
PKG_VERSION="1.4.10"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr        \
	            --sysconfdir=/etc    \
    	        --localstatedir=/var \
    	        --without-mbim		 \
    	        --without-qmi		 \
    	        --disable-static     &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL install
	systemctl enable ModemManager	
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
