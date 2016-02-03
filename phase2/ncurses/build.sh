#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="ncurses"
PKG_VERSION="6.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
    ./configure	--prefix=/usr        	\
				--with-shared           \
				--without-debug         \
				--without-normal        \
				--enable-pc-files       \
				--enable-widec
    make $MAKE_PARALLEL
}

function check() {
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install
    
    mv -v /usr/lib/libncursesw.so.6* /lib
    ln -sfv ../../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
    
    for lib in ncurses form panel menu ; do
	rm -vf                    /usr/lib/lib${lib}.so
	echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
	ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
    done
    
    rm -vf                     /usr/lib/libcursesw.so
    echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
    ln -sfv libncurses.so      /usr/lib/libcurses.so    
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
