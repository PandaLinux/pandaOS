#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="Python"
PKG_VERSION="3.5.0"

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
	CXX="/usr/bin/g++" 				\
	./configure --prefix=/usr       \
	            --enable-shared     \
    	        --with-system-expat \
    	        --with-system-ffi   \
    	        --without-ensurepip &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install &&
	chmod -v 755 /usr/lib/libpython3.5m.so &&
	chmod -v 755 /usr/lib/libpython3.so
	
	install -v -dm755 /usr/share/doc/python-${PKG_VERSION}/html &&
	tar --strip-components=1 \
    	--no-same-owner \
    	--no-same-permissions \
    	-C /usr/share/doc/python-${PKG_VERSION}/html \
    	-xvf /source/${DOCS_TARBALL}
    	
    echo "export PYTHONDOCS=/usr/share/doc/python-${PKG_VERSION}/html" >> /etc/profile
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
