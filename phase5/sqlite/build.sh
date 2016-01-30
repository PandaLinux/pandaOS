#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="sqlite"
PKG_VERSION="3090200"

TARBALL="${PKG_NAME}-autoconf-${PKG_VERSION}.tar.gz"
DOCS_TARBALL="${PKG_NAME}-doc-${PKG_VERSION}.zip"
SRC_DIR="${PKG_NAME}-autoconf-${PKG_VERSION}"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "/source/$TARBALL" "$TARBALL"
        ln -sv "/source/$DOCS_TARBALL" "$DOCS_TARBALL"
    fi
}

function unpack() {
    tar xf ${TARBALL}
    unzip -q $DOCS_TARBALL
}

function build() {
	./configure --prefix=/usr --disable-static        			\
	            CFLAGS="-g -O2 -DSQLITE_ENABLE_FTS3=1 			\
			            -DSQLITE_ENABLE_COLUMN_METADATA=1     	\
			            -DSQLITE_ENABLE_UNLOCK_NOTIFY=1       	\
			            -DSQLITE_SECURE_DELETE=1" &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install
	
	install -v -m755 -d /usr/share/doc/sqlite-3.9.2 &&
	cp -v -R ../${PKG_NAME}-doc-${PKG_VERSION}/* /usr/share/doc/sqlite-3.9.2
}

function clean() {
    rm -rf "${SRC_DIR}" "${PKG_NAME}-doc-${PKG_VERSION}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
