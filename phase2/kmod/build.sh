#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="kmod"
PKG_VERSION="22"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {    
    ./configure --prefix=/usr          \
				--bindir=/bin          \
				--sysconfdir=/etc      \
				--with-rootlibdir=/lib \
				--with-xz              \
				--with-zlib    
    make $MAKE_PARALLEL
}

function check() {
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install
    
    for target in depmod insmod lsmod modinfo modprobe rmmod; do
		ln -sv ../bin/kmod /sbin/$target
    done

    ln -sv kmod /bin/lsmod
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
