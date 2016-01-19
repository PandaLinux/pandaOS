#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="apt"
PKG_VERSION="1.1.10"

TARBALL="${PKG_NAME}-${PKG_VERSION}.zip"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "../../source/$TARBALL" "$TARBALL"
    fi
}

function unpack() {
    unzip -q ${TARBALL}
}

function build() {
	automake --add-missing
	aclocal -I buildlib
	autoconf
	touch buildlib/config.rpath

    mkdir "${BUILD_DIR}" &&
    cd "${BUILD_DIR}"
    
    ../configure --prefix=/usr \
    			 --docdir=/usr/share/doc/${PKG_NAME}-${PKG_VERSION} &&
    make -j1
}

function check() {
	echo " "
}

function instal() {
	cp -rv bin/apt* /usr/bin &&
	cp -rv bin/libapt* /usr/lib &&
	mkdir -pv /etc/apt/{apt.conf.d,sources.list.d,preferences.d} &&
	mkdir -pv /usr/lib/apt &&
	cp -rv bin/methods /usr/lib/apt &&
    cat > /etc/apt/sources.list << "EOF"
## Begin /etc/apt/sources.list

deb http://panda-linux.esy.es/ftp/panda black main
deb-src http://panda-linux.esy.es/ftp/panda black main

## End /etc/apt/sources.list
EOF

}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;
#clean
