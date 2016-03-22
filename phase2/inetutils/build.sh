#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="inetutils"
PKG_VERSION="1.9.4"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {    
    ./configure --prefix=/usr 	     \
				--localstatedir=/var \
				--disable-logger     \
				--disable-whois      \
				--disable-rcp        \
				--disable-rexec      \
				--disable-rlogin     \
				--disable-rsh        \
				--disable-servers
    make $MAKE_PARALLEL
}

function check() {
   make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install
    mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
    mv -v /usr/bin/ifconfig /sbin
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
