#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="iproute2"
PKG_VERSION="4.2.0"

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
    sed -i '/^TARGETS/s@arpd@@g' misc/Makefile
    sed -i /ARPD/d Makefile
    sed -i 's/arpd.8//' man/man8/Makefile
    make $MAKE_PARALLEL
}

function check() {
    echo "Nothing to be done here."
}

function instal() {
    make $MAKE_PARALLEL DOCDIR=/usr/share/doc/iproute2-4.2.0 install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean