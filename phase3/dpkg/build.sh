#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="dpkg"
PKG_VERSION="1.17.25"

TARBALL="${PKG_NAME}_${PKG_VERSION}.tar.xz"
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
    autoreconf -f -i
    ./configure --prefix=/usr	&&
    make $MAKE_PARALLEL
}

function check() {
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install
    touch /usr/var/lib/${PKG_NAME}/{status,available} &&
    mkdir -pv /var/lib/${PKG_NAME} &&
    touch /var/lib/${PKG_NAME}/status
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
