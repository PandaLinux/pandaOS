#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="dpkg"
PKG_VERSION="1.17.25"

TARBALL="${PKG_NAME}_${PKG_VERSION}.tar.xz"
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
	patch -p0 -i ../dpkg-gzip-rsyncable.patch
    autoreconf -f -i
    ./configure --prefix=/usr 				\
    			--sysconfdir=/etc 			\
    			--localstatedir=/var		\
    			--sbindir=/usr/bin			\
    			--disable-start-stop-daemon	\
    			--with-zlib					\
    			--with-liblzma				&&
    make $MAKE_PARALLEL
}

function check() {
    echo " "
}

function instal() {
    make $MAKE_PARALLEL install
    touch /var/lib/${PKG_NAME}/{status,available}
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
