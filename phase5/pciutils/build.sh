#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="pciutils"
PKG_VERSION="3.4.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	make 	PREFIX=/usr                \
			SHAREDIR=/usr/share/hwdata \
			SHARED=yes
}

function check() {
	echo ""
}

function instal() {
	make 	PREFIX=/usr  i             \
			SHAREDIR=/usr/share/hwdata \
			SHARED=yes                 \
			install install-lib        &&
	chmod -v 755 /usr/lib/libpci.so
	update-pciids
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
