#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="bash"
PKG_VERSION="4.3.30"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
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
    patch -Np1 -i ../bash-4.3.30-upstream_fixes-2.patch
    
    ./configure --prefix=/usr                       \
		--bindir=/bin                       \
		--docdir=/usr/share/doc/bash-4.3.30 \
		--without-bash-malloc               \
		--with-installed-readline
    make $MAKE_PARALLEL
}

function check() {
    chown -Rv nobody .
    su nobody -s /bin/bash -c "PATH=$PATH make $MAKE_PARALLEL tests"
}

function instal() {
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean