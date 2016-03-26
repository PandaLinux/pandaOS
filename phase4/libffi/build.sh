#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="libffi"
PKG_VERSION="3.2.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	sed -e '/^includesdir/ s/$(libdir).*$/$(includedir)/' \
    	-i include/Makefile.in &&

	sed -e '/^includedir/ s/=.*$/=@includedir@/' \
    	-e 's/^Cflags: -I${includedir}/Cflags:/' \
    	-i libffi.pc.in        &&

	./configure --prefix=/usr --disable-static &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
