#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="e2fsprogs"
PKG_VERSION="1.42.13"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

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
	mkdir $BUILD_DIR
	cd $BUILD_DIR

    LIBS=-L/tools/lib                    \
    CFLAGS=-I/tools/include              \
    PKG_CONFIG_PATH=/tools/lib/pkgconfig \
    ../configure --prefix=/usr           	\
	             --bindir=/bin		 		\
	             --with-root-prefix=""   	\
	             --enable-elf-shlibs     	\
	             --disable-libblkid      	\
	             --disable-libuuid       	\
	             --disable-uuidd         	\
	             --disable-fsck
    make $MAKE_PARALLEL tooldir=/usr
}

function check() {
    ln -sfv /tools/lib/lib{blk,uu}id.so.1 lib
    make $MAKE_PARALLEL LD_LIBRARY_PATH=/tools/lib check
}

function instal() {
    make $MAKE_PARALLEL install
    make $MAKE_PARALLEL install-libs
    
    chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
    gunzip -v /usr/share/info/libext2fs.info.gz
    install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
