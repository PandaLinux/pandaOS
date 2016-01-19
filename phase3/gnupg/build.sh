#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="gnupg"
PKG_VERSION="2.1.7"

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
    	        --enable-symcryptrun \
    	        --docdir=/usr/share/doc/gnupg-2.1.7 &&
	make $MAKE_PARALLEL &&

	makeinfo --html --no-split -o doc/gnupg_nochunks.html doc/gnupg.texi &&
	makeinfo --plaintext       -o doc/gnupg.txt           doc/gnupg.texi
}

function check() {
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL install &&

	for f in gpg gpgv ; do
		ln -sfv ${f}2   /usr/bin/${f} &&
		ln -sfv ${f}2.1 /usr/share/man/man1/${f}.1
	done &&

	install -v -dm755 /usr/share/doc/${PKG_NAME}-${PKG_VERSION}/html       &&
	install -v -m644  doc/gnupg_nochunks.html \
	                  /usr/share/doc/${PKG_NAME}-${PKG_VERSION}/gnupg.html &&
	install -v -m644  doc/*.texi doc/gnupg.txt \
    	              /usr/share/doc/${PKG_NAME}-${PKG_VERSION}
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
