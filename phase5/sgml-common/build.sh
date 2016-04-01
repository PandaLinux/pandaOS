#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="sgml-common"
PKG_VERSION="0.6.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tgz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	patch -Np1 -i ../$PKG_NAME-$PKG_VERSION-manpage-1.patch &&
	autoreconf -f -i
	
	./configure --prefix=/usr --sysconfdir=/etc &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install
	
	install-catalog --add /etc/sgml/sgml-ent.cat \
		/usr/share/sgml/sgml-iso-entities-8879.1986/catalog &&

	install-catalog --add /etc/sgml/sgml-docbook.cat \
		/etc/sgml/sgml-ent.cat
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
