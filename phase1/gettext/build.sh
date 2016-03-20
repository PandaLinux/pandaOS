#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gettext"
PKG_VERSION="0.19.7"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "../../source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    cd gettext-tools
    EMACS="no" ./configure --prefix=/tools --disable-shared
    make $MAKE_PARALLEL -C gnulib-lib
    make $MAKE_PARALLEL -C intl pluralx.c
    make $MAKE_PARALLEL -C src msgfmt
    make $MAKE_PARALLEL -C src msgmerge
    make $MAKE_PARALLEL -C src xgettext
}

function check() {
    echo " "
}

function instal() {
    cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
