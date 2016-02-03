#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="gtk+"
PKG_VERSION="2.24.29"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    sed -e 's#l \(gtk-.*\).sgml#& -o \1#' \
    -i docs/{faq,tutorial}/Makefile.in      &&

	./configure --prefix=/usr --sysconfdir=/etc &&
    make $MAKE_PARALLEL
}

function check() {
	# The tests should be run from within the system.
	#
	# make $MAKE_PARALLEL check
	#
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
