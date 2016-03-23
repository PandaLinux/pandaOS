#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="dpkg"
PKG_VERSION="1.18.4"

TARBALL="${PKG_NAME}_${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    autoreconf -f -i
    ./configure --prefix=/usr 				\
    			--sysconfdir=/etc 			\
    			--localstatedir=/var		\
    			--sbindir=/usr/bin			\
    			--disable-start-stop-daemon	\
    			--with-zlib					\
    			--with-bz2					\
    			--with-liblzma				&&
    make $MAKE_PARALLEL
}

function check() {
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install
	install -d "/var/dpkg/updates/"
    touch /var/lib/${PKG_NAME}/{status,available}
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
