#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="bash"
PKG_VERSION="4.3.30"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../$PKG_NAME-$PKG_VERSION-upstream_fixes-3.patch
    
    ./configure --prefix=/usr                       \
				--without-bash-malloc               \
				--with-installed-readline
    make $MAKE_PARALLEL
}

function check() {
    chown -Rv nobody .
    su nobody -s /bin/bash -c "PATH=$PATH make tests"
}

function instal() {
    make $MAKE_PARALLEL install
    mv -vf /usr/bin/bash /bin
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
