#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="nano"
PKG_VERSION="2.4.2"

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
    ./configure --prefix=/usr     \
	            --sysconfdir=/etc \
    	        --enable-utf8     \
    	        --docdir=/usr/share/doc/${PKG_NAME}-${PKG_VERSION} &&
    make $MAKE_PARALLEL
}

function check() {
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install &&
	install -v -m644 doc/nanorc.sample /etc &&
	install -v -m644 doc/texinfo/nano.html /usr/share/doc/${PKG_NAME}-${PKG_VERSION}
	
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
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
