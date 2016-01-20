#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="xterm"
PKG_VERSION="320"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tgz"
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
	sed -i '/v0/{n;s/new:/new:kb=^?:/}' termcap &&
	printf '\tkbs=\\177,\n' >> terminfo &&

	TERMINFO=/usr/share/terminfo \
	./configure $XORG_CONFIG     \
    			--with-app-defaults=/etc/X11/app-defaults &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install &&
	make $MAKE_PARALLEL install-ti
	
	cat >> /etc/X11/app-defaults/XTerm << "EOF"
*VT100*locale: true
*VT100*faceName: Monospace
*VT100*faceSize: 10
*backarrowKeyIsErase: true
*ptyInitialErase: true
EOF
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
