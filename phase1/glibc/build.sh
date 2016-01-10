#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="glibc"
PKG_VERSION="2.22"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
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
    patch -Np1 -i ../glibc-2.22-upstream_i386_fix-1.patch
    
    mkdir "${BUILD_DIR}" &&
    cd "${BUILD_DIR}" &&
    ../configure  \
        --prefix=/tools                    \
        --host="$TARGET"                   \
        --build=$(../scripts/config.guess) \
        --disable-profile                  \
        --enable-kernel=2.6.32             \
        --enable-obsolete-rpc              \
        --with-headers=/tools/include      \
        libc_cv_forced_unwind=yes          \
        libc_cv_ctors_header=yes           \
        libc_cv_c_cleanup=yes
    
     make -j1
     make -j1 install
    
     echo 'int main(){}' > dummy.c
     "$TARGET-gcc" dummy.c
     readelf -l a.out | grep ': /tools' |& tee test.log
     rm -v dummy.c a.out
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;popd;clean
