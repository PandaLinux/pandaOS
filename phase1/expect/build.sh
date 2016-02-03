#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="expect"
PKG_VERSION="5.45"

TARBALL="${PKG_NAME}${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}${PKG_VERSION}"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "../../source/$TARBALL" "$TARBALL"
    fi
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    cp -v configure{,.orig}
    sed 's:/usr/local/bin:/bin:' configure.orig > configure
    ./configure --prefix=/tools       		\
	            --with-tcl=/tools/lib     	\
    	        --with-tclinclude=/tools/include
    make $MAKE_PARALLEL
}

function check(){
	make $MAKE_PARALLEL test
}

function instal(){
	make $MAKE_PARALLEL SCRIPTS="" install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;instal;check;popd;clean
