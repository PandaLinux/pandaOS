#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="util-linux"
PKG_VERSION="2.27.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    mkdir -pv /var/lib/hwclock
    ./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
				--disable-chfn-chsh  \
				--disable-login      \
				--disable-nologin    \
				--disable-su         \
				--disable-setpriv    \
				--disable-runuser    \
				--disable-pylibmount \
				--disable-static     \
				--without-python  
    make $MAKE_PARALLEL
}

function check() {
    chown -Rv nobody .
    su nobody -s /bin/bash -c "PATH=$PATH make -k check"
}

function instal() {
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
