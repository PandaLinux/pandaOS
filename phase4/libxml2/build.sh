#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="libxml2"
PKG_VERSION="2.9.3"

TEST_TARBALL="xmlts20130923.tar.gz"
TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
    ln -sv "/source/$TEST_TARBALL" "$TEST_TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
    tar xf ${TEST_TARBALL}
}

function build() {
	sed \
	  -e /xmlInitializeCatalog/d \
	  -e 's/((ent->checked =.*&&/(((ent->checked == 0) ||\
          ((ent->children == NULL) \&\& (ctxt->options \& XML_PARSE_NOENT))) \&\&/' \
	  -i parser.c
	 
	./configure --prefix=/usr --disable-static --with-history &&
	make $MAKE_PARALLEL
}

function check() {	
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL" "${TEST_TARBALL}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
