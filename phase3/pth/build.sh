#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="pth"
PKG_VERSION="2.0.7"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
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
    sed -i 's#$(LOBJS): Makefile#$(LOBJS): pth_p.h Makefile#' Makefile.in &&
	./configure --prefix=/usr           \
    	        --disable-static        \
    	        --mandir=/usr/share/man &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL test
}

function instal() {
	make $MAKE_PARALLEL install &&

	install -v -m755 -d /usr/share/doc/${PKG_NAME}-${PKG_VERSION} &&
	install -v -m644    README PORTING SUPPORT TESTS \
    	                /usr/share/doc/${PKG_NAME}-${PKG_VERSION}
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
