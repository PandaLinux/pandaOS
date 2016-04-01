#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="bluez"
PKG_VERSION="5.37"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	patch -Np1 -i ../$PKG_NAME-$PKG_VERSION-obexd_without_systemd-1.patch &&
	./configure --prefix=/usr        \
    	        --sysconfdir=/etc    \
    	        --localstatedir=/var \
    	        --enable-library     &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL install &&
	ln -svf ../libexec/bluetooth/bluetoothd /usr/sbin
	
	install -v -dm755 /etc/bluetooth &&
	install -v -m644 src/main.conf /etc/bluetooth/main.conf
	
	systemctl enable bluetooth
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
