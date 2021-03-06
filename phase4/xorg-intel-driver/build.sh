#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="xf86-video-intel"
PKG_VERSION="0340718"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	sed -i "/#include <errno.h>/a #include <sys/stat.h>" src/uxa/intel_driver.c &&
	sed -i "/#include <errno.h>/a #include <sys/stat.h>" src/sna/sna_driver.c &&
	./configure $XORG_CONFIG --enable-kms-only &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install
	
	cat >> /etc/X11/xorg.conf.d/20-intel.conf << "EOF"
Section "Device"
        Identifier "Intel Graphics"
        Driver "intel"
        Option "AccelMethod" "uxa"
EndSection
EOF
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
