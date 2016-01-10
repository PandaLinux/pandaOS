#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="gcc"
PKG_VERSION="5.2.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
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
    mkdir "${BUILD_DIR}" &&
    cd "${BUILD_DIR}" &&
    SED=sed 			 \
    ../configure		 \
    	--prefix=/usr            \
	--enable-languages=c,c++ \
	--disable-multilib       \
	--disable-bootstrap      \
	--with-system-zlib
     make $MAKE_PARALLEL
}

function check() {
    ulimit -s 32768
    make $MAKE_PARALLEL -k check
    ../contrib/test_summary
}

function instal() {
    make $MAKE_PARALLEL install
    ln -sv ../../../../usr/bin/cpp /lib
    ln -sv gcc /usr/bin/cc
    install -v -dm755 /usr/lib/bfd-plugins
    ln -sfv ../../../../libexec/gcc/$(gcc -dumpmachine)/5.2.0/liblto_plugin.so /usr/lib/bfd-plugins/
}

function sanityCheck() {
    echo 'int main(){}' > sanity.c
    cc sanity.c -v -Wl,--verbose &> sanity.log
    readelf -l a.out | grep ': /lib'
    
    grep -o '/usr/lib.*/crt[1in].*succeeded' sanity.log
    grep -B4 '^ /usr/include' sanity.log
    grep 'SEARCH.*/usr/lib' sanity.log |sed 's|; |\n|g'
    grep "/lib.*/libc.so.6 " sanity.log
    grep found sanity.log
    rm -v sanity.c a.out
    
    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean