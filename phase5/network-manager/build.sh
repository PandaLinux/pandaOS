#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="NetworkManager"
PKG_VERSION="1.0.6"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr                   \
	            --sysconfdir=/etc               \
    	        --localstatedir=/var            \
    	        --disable-ppp                   \
    	        --without-iptables				\
    	        --with-session-tracking=systemd \
    	        --with-systemdsystemunitdir=/lib/systemd/system &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL check
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
