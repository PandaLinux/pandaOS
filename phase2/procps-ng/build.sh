#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="procps-ng"
PKG_VERSION="3.3.11"

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
    ./configure --prefix=/usr				 \
				--exec-prefix=				 \
				--libdir=/usr/lib			 \
				--disable-static			 \
				--disable-kill
    make $MAKE_PARALLEL
}

function check() {
    sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install
    
    mv -v /usr/lib/libprocps.so.* /lib
    ln -sfv ../../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
