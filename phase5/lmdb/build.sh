#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="LMDB"
PKG_VERSION="0.9.17"

TARBALL="${PKG_NAME}_${PKG_VERSION}.tar.gz"
SRC_DIR="lmdb-${PKG_NAME}_${PKG_VERSION}"

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
	cd libraries/liblmdb                     &&
	sed -i 's|prefix)/man|mandir)|' Makefile &&
	make $MAKE_PARALLEL                      &&
	sed -i 's| liblmdb.a||'         Makefile
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL prefix=/usr mandir=/usr/share/man install
	
	update-desktop-database
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
