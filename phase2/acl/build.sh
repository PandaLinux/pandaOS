#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="acl"
PKG_VERSION="2.2.52"

TARBALL="${PKG_NAME}-${PKG_VERSION}.src.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
    sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test
    
    sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" \
	    libacl/__acl_to_any_text.c
    
    ./configure	--prefix=/usr       \
				--disable-static    \
				--libexecdir=/usr/lib
    
    make $MAKE_PARALLEL
}

function check() {
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install install-dev install-lib
    chmod -v 755 /usr/lib/libacl.so
    
    mv -v /usr/lib/libacl.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
