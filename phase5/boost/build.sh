#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="boost"
PKG_VERSION="1_60_0"

TARBALL="${PKG_NAME}_${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}_${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	sed -e '/using python/ s@;@: /usr/include/python${PYTHON_VERSION/3*/${PYTHON_VERSION}m} @' \
	    -i bootstrap.sh
	    
	sed -e '1 i#ifndef Q_MOC_RUN' \
    	-e '$ a#endif'            \
    	-i boost/type_traits/detail/has_binary_operator.hpp &&

	./bootstrap.sh --prefix=/usr --with-python=python3
	./b2 $MAKE_PARALLEL stage threading=multi link=shared
}

function check() {
	pushd tools/build/test; python test_all.py; popd
	pushd status; ../b2 $MAKE_PARALLEL; popd
}

function instal() {
	./b2 $MAKE_PARALLEL install threading=multi link=shared
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
