#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="kmod"
PKG_VERSION="21"

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
    ./configure --prefix=/usr          \
		--bindir=/bin          \
		--sysconfdir=/etc      \
		--with-rootlibdir=/lib \
		--with-xz              \
		--with-zlib
    
    make $MAKE_PARALLEL
}

function check() {
    echo "Nothing to be done here."
}

function instal() {
    make $MAKE_PARALLEL install
    
    for target in depmod insmod lsmod modinfo modprobe rmmod; do
	ln -sv ../../../bin/kmod /sbin/$target
    done

    ln -sv kmod /bin/lsmod
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean