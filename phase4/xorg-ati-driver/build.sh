#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="xf86-video-ati"
PKG_VERSION="7.5.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
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
	./configure $XORG_CONFIG &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install
	
	cat >> /etc/X11/xorg.conf.d/20-glamor.conf << "EOF"
Section "Device"
        Identifier "radeon"
        Driver "radeon"
        Option "AccelMethod" "glamor"
EndSection
EOF
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
