#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="binutils"
PKG_VERSION="2.25.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "../../source/$TARBALL" "$TARBALL"
    fi
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    mkdir "${BUILD_DIR}" &&
    cd "${BUILD_DIR}" &&
    ../configure               		\
	    --prefix=/tools            	\
	    --with-sysroot=$MOUNT_POINT \
	    --with-lib-path=/tools/lib 	\
	    --target=$TARGET       	\
	    --disable-nls              	\
	    --disable-werror
    make $MAKE_PARALLEL
    
    case $(uname -m) in
        x86_64) mkdir /tools/lib && ln -s lib /tools/lib64 ;;
    esac
    
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;popd;clean;
