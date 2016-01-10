#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="bc"
PKG_VERSION="1.06.95"

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
    patch -Np1 -i ../bc-1.06.95-memory_leak-1.patch
    
    ./configure --prefix=/usr           \
		--with-readline         \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info
    make $MAKE_PARALLEL
}

function check() {
    echo "quit" | ./bc/bc -l Test/checklib.b
}

function instal() {
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean