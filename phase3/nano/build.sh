#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="nano"
PKG_VERSION="2.4.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {    
    ./configure --prefix=/usr     \
	            --sysconfdir=/etc \
    	        --enable-utf8     &&
    make $MAKE_PARALLEL
}

function check() {
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install &&
	install -v -m644 doc/nanorc.sample /etc
	
	cat > /etc/nanorc << "EOF"
## Begin /etc/nanorc

set autoindent
set const
set fill 72
set historylog
set multibuffer
set nohelp
set regexp
set smooth
set suspend

## End /etc/nanorc
EOF
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
