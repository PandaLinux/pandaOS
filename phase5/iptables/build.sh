#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="iptables"
PKG_VERSION="1.6.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr   \
				--sbindir=/sbin \
				--disable-nftables \
				--enable-libipq \
				--with-xtlibdir=/lib/xtables &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make install &&
	ln -sfv ../../sbin/xtables-multi /usr/bin/iptables-xml &&

	for file in ip4tc ip6tc ipq iptc xtables
	do
		mv -v /usr/lib/lib${file}.so.* /lib &&
		ln -sfv ../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
	done
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
