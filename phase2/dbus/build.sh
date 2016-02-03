#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="dbus"
PKG_VERSION="1.8.20"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
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
    ./configure --prefix=/usr                       \
				--sysconfdir=/etc                   \
				--localstatedir=/var                \
				--disable-static                    \
				--with-console-auth-dir=/run/console
    
    make $MAKE_PARALLEL
}

function check() {
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install
    
    mv -v /usr/lib/libdbus-1.so.* /lib
    ln -sfv ../../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so
    ln -sfv /etc/machine-id /var/lib/dbus
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
