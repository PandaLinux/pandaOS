#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="libgcrypt"
PKG_VERSION="1.6.4"

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
    ./configure --prefix=/usr &&
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install &&
	install -v -dm755   /usr/share/doc/${PKG_NAME}-${PKG_VERSION} &&
	install -v -m644    README doc/{README.apichanges,fips*,libgcrypt*} \
    	                /usr/share/doc/${PKG_NAME}-${PKG_VERSION}
    	                
	mv -v /usr/lib/libgcrypt.so.* /lib
	ln -sfv ../../../lib/$(readlink /usr/lib/libgcrypt.so) /usr/lib/libgcrypt.so
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
