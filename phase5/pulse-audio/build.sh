#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="pulseaudio"
PKG_VERSION="8.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	sed -i "/seems to be moved/s/^/#/" build-aux/ltmain.sh
	
	./configure --prefix=/usr        \
	            --sysconfdir=/etc    \
    	        --localstatedir=/var \
    	        --disable-bluez4     \
    	        --disable-rpath      &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL install
	rm /etc/dbus-1/system.d/pulseaudio-system.conf
	sed -i '/load-module module-console-kit/s/^/#/' /etc/pulse/default.pa
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
