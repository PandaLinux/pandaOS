#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="llvm"
PKG_VERSION="3.7.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.src.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}.src"
BUILD_DIR="${PKG_NAME}-build"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	sed -e "s:/docs/llvm:/share/doc/llvm-3.7.1:" \
    -i Makefile.config.in &&
	    
	mkdir "$BUILD_DIR" &&
	cd "$BUILD_DIR"

	CC=gcc CXX=g++                   	\
	../configure --prefix=/usr          \
             --datarootdir=/usr/share   \
             --sysconfdir=/etc          \
             --enable-libffi            \
             --enable-optimized         \
             --enable-shared            \
             --enable-targets=host,r600 \
             --disable-assertions 		&&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL -k check-all
}

function instal() {
	make $MAKE_PARALLEL install &&

	for file in /usr/lib/lib{clang,LLVM,LTO}*.a
	do
		test -f $file && chmod -v 644 $file
	done &&
	unset file
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
