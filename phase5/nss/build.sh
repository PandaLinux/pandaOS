#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="nss"
PKG_VERSION="3.22.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	patch -Np1 -i ../$PKG_NAME-$PKG_VERSION-standalone-1.patch &&

	cd nss &&
	make BUILD_OPT=1                      	\
		NSPR_INCLUDE_DIR=/usr/include/nspr  \
		USE_SYSTEM_ZLIB=1                   \
		ZLIB_LIBS=-lz                       \
		$([ $(uname -m) = x86_64 ] && echo USE_64=1) \
		$([ -f /usr/include/sqlite3.h ] && echo NSS_USE_SYSTEM_SQLITE=1) -j1
}

function check() {
	echo " "
}

function instal() {
	cd ../dist                                                       &&
	install -v -m755 Linux*/lib/*.so              /usr/lib           &&
	install -v -m644 Linux*/lib/{*.chk,libcrmf.a} /usr/lib           &&
	install -v -m755 -d                           /usr/include/nss   &&
	cp -v -RL {public,private}/nss/*              /usr/include/nss   &&
	chmod -v 644                                  /usr/include/nss/* &&
	install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} /usr/bin &&
	install -v -m644 Linux*/lib/pkgconfig/nss.pc  /usr/lib/pkgconfig
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
