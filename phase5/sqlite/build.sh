#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="sqlite"
PKG_VERSION="3110000"

TARBALL="${PKG_NAME}-autoconf-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-autoconf-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure --prefix=/usr --disable-static        \
				CFLAGS="-g -O2 -DSQLITE_ENABLE_FTS3=1 \
				-DSQLITE_ENABLE_COLUMN_METADATA=1     \
				-DSQLITE_ENABLE_UNLOCK_NOTIFY=1       \
				-DSQLITE_SECURE_DELETE=1              \
				-DSQLITE_ENABLE_DBSTAT_VTAB=1" &&
	make -j1
}

function check() {
	echo " "
}

function instal() {
	make -j1 install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
