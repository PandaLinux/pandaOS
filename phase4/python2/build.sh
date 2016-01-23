#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="Python"
PKG_VERSION="2.7.10"

DOCS_TARBALL="python-${PKG_VERSION}-docs-html.tar.bz2"
TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
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
	./configure --prefix=/usr       \
	            --enable-shared     \
    	        --with-system-expat \
    	        --with-system-ffi   \
    	        --enable-unicode=ucs4 &&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL test
}

function instal() {
	make $MAKE_PARALLEL install &&
	chmod -v 755 /usr/lib/libpython2.7.so.1.0
	
	install -v -dm755 /usr/share/doc/python-${PKG_VERSION} &&
	tar --strip-components=1 -C /usr/share/doc/python-${PKG_VERSION} \
    	--no-same-owner -xvf /source/${DOCS_TARBALL}      &&
	find /usr/share/doc/python-${PKG_VERSION} -type d -exec chmod 0755 {} \; &&
	find /usr/share/doc/python-${PKG_VERSION} -type f -exec chmod 0644 {} \;
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
