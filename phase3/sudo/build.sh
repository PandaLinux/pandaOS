#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="sudo"
PKG_VERSION="1.8.14p3"

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
    ./configure --prefix=/usr              \
	            --libexecdir=/usr/lib      \
    	        --with-secure-path         \
    	        --with-all-insults         \
    	        --with-env-editor          \
    	        --docdir=/usr/share/doc/${PKG_NAME}-${PKG_VERSION} \
    	        --with-passprompt="[sudo] password for %p" &&
    make $MAKE_PARALLEL
}

function check() {
    env LC_ALL=C make $MAKE_PARALLEL check 2>&1 | tee ../make-check.log
    grep failed ../make-check.log
}

function instal() {
    make $MAKE_PARALLEL install &&
	ln -sfv libsudo_util.so.0.0.0 /usr/lib/sudo/libsudo_util.so.0
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
