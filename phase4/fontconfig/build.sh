#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="fontconfig"
PKG_VERSION="2.11.1"

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
    ./configure --prefix=/usr        \
		--sysconfdir=/etc    \
		--localstatedir=/var \
		--disable-docs       \
		--docdir=/usr/share/doc/$PKG_NAME-$PKG_VERSION &&
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    make $MAKE_PARALLEL install
    
    install -v -dm755 \
        /usr/share/{man/man{3,5},doc/$PKG_NAME-$PKG_VERSION/fontconfig-devel} &&
    install -v -m644 fc-*/*.1          /usr/share/man/man1 &&
    install -v -m644 doc/*.3           /usr/share/man/man3 &&
    install -v -m644 doc/fonts-conf.5  /usr/share/man/man5 &&
    install -v -m644 doc/fontconfig-devel/* 	\
	    /usr/share/doc/$PKG_NAME-$PKG_VERSION/fontconfig-devel &&
    install -v -m644 doc/*.{pdf,sgml,txt,html} 	\
	    /usr/share/doc/$PKG_NAME-$PKG_VERSION
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean