#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="man-db"
PKG_VERSION="2.7.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
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
    ./configure --prefix=/usr                        \
		--sysconfdir=/etc                    \
		--disable-setuid                     \
		--with-browser=/usr/bin/lynx         \
		--with-vgrind=/usr/bin/vgrind        \
		--with-grap=/usr/bin/grap
    
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install
    sed -i "s:man root:root root:g" /usr/lib/tmpfiles.d/man-db.conf
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
