#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="NetworkManager"
PKG_VERSION="1.0.10"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr --build=x86_64-unknown-linux-gnu --host=x86_64-unknown-linux-gnu --sysconfdir=/etc --localstatedir=/var --disable-ppp --with-session-tracking=systemd --with-systemdsystemunitdir=/lib/systemd/system
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install
	
	cat >> /etc/NetworkManager/NetworkManager.conf << "EOF"
[main]
plugins=keyfile
dns=none
EOF

	systemctl enable NetworkManager
	systemctl enable NetworkManager-wait-online
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
