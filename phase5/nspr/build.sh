#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="nspr"
PKG_VERSION="4.12"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	cd nspr                                                     &&
	sed -ri 's#^(RELEASE_BINS =).*#\1#' pr/src/misc/Makefile.in &&
	sed -i 's#$(LIBRARY) ##' config/rules.mk                    &&

	./configure --prefix=/usr \
				--with-mozilla \
				--with-pthreads \
				$([ $(uname -m) = x86_64 ] && echo --enable-64bit) &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
