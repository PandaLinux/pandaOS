#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="tcl"
PKG_VERSION="8.6.4"

TARBALL="${PKG_NAME}${PKG_VERSION}-src.tar.gz"
SRC_DIR="${PKG_NAME}${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	export SRCDIR=`pwd` &&
	cd unix &&

	./configure --prefix=/usr           \
    	        $([ $(uname -m) = x86_64 ] && echo --enable-64bit) &&
	make $MAKE_PARALLEL &&

	sed -e "s#$SRCDIR/unix#/usr/lib#" \
    	-e "s#$SRCDIR#/usr/include#"  \
    	-i tclConfig.sh               &&

	sed -e "s#$SRCDIR/unix/pkgs/tdbc1.0.3#/usr/lib/tdbc1.0.3#" \
    	-e "s#$SRCDIR/pkgs/tdbc1.0.3/generic#/usr/include#"    \
    	-e "s#$SRCDIR/pkgs/tdbc1.0.3/library#/usr/lib/tcl8.6#" \
    	-e "s#$SRCDIR/pkgs/tdbc1.0.3#/usr/include#"            \
    	-i pkgs/tdbc1.0.3/tdbcConfig.sh                        &&

	sed -e "s#$SRCDIR/unix/pkgs/itcl4.0.3#/usr/lib/itcl4.0.3#" \
    	-e "s#$SRCDIR/pkgs/itcl4.0.3/generic#/usr/include#"    \
    	-e "s#$SRCDIR/pkgs/itcl4.0.3#/usr/include#"            \
    	-i pkgs/itcl4.0.3/itclConfig.sh                        &&

	unset SRCDIR
}

function check() {
	make $MAKE_PARALLEL test
}

function instal() {
	make $MAKE_PARALLEL install &&
	make $MAKE_PARALLEL install-private-headers &&
	ln -sfv tclsh8.6 /usr/bin/tclsh &&
	chmod -v 755 /usr/lib/libtcl8.6.so	
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
