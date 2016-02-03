#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="vim"
PKG_VERSION="7.4"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}74"

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
    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
    ./configure --prefix=/usr    
    make $MAKE_PARALLEL
}

function check() {
    make -j1 test
}

function instal() {
    make $MAKE_PARALLEL install
    
    ln -sv vim /usr/bin/vi
    for L in  /usr/share/man/{,*/}man1/vim.1; do
	ln -sv vim.1 $(dirname $L)/vi.1
    done
    
    cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

set nocompatible
set backspace=2
syntax on
if (&term == "iterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
