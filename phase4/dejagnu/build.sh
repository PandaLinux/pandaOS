#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="dejagnu"
PKG_VERSION="1.5.3"

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
	./configure --prefix=/usr &&
	makeinfo --html --no-split -o doc/dejagnu.html doc/dejagnu.texi &&
	makeinfo --plaintext       -o doc/dejagnu.txt  doc/dejagnu.texi
}

function check() {
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL install &&
	install -v -dm755   /usr/share/doc/${PKG_NAME}-${PKG_VERSION} &&
	install -v -m644    doc/dejagnu.{html,txt} \
    	                /usr/share/doc/${PKG_NAME}-${PKG_VERSION}
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
