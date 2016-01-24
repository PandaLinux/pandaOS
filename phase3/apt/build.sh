#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="apt"
PKG_VERSION="1.2"

TARBALL="${PKG_NAME}_${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

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
	pushd buildlib
		wget -O config.guess 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD'
		wget -O config.sub 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'
		touch config.rpath
	popd
	
	wget -c http://ftp.debian.org/debian/pool/main/g/gtest/libgtest-dev_1.7.0-3_amd64.deb
	
	dpkg -i libgtest-dev_1.7.0-3_amd64.deb

	./configure
    make $MAKE_PARALLEL
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
	
	# Add the sandbox user '_apt'
	sudo useradd -r -M --system _apt

	sudo wget http://panda-linux.esy.es/ftp/panda/panda-key.gpg -O- | sudo apt-key add -
	sudo apt update
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
