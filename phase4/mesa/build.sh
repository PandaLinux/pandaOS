#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="mesa"
PKG_VERSION="11.0.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure CFLAGS="-O2" CXXFLAGS="-O2"  \
	            --prefix=/usr                \
    	        --sysconfdir=/etc            \
    	        --enable-texture-float       \
    	        --enable-gles1               \
    	        --enable-gles2               \
    	        --enable-glx-tls             \
    	        --enable-osmesa              \
    	        --with-egl-platforms="drm,x11,wayland" \
    	        --with-gallium-drivers="nouveau,r300,r600,radeonsi,svga,swrast" &&
	make $MAKE_PARALLEL
}

function check() {	
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
