#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="xorg-server"
PKG_VERSION="1.17.2"

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
    patch -Np1 -i ../xorg-server-1.17.2-add_prime_support-1.patch

    ./configure $XORG_CONFIG          \
		--enable-glamor       \
		--enable-suid-wrapper \
		--with-xkb-output=/var/lib/xkb &&
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install &&
    mkdir -pv /etc/X11/xorg.conf.d
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean