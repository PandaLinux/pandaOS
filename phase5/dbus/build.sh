#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="dbus"
PKG_VERSION="1.8.20"

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
	./configure --prefix=/usr                        \
	            --sysconfdir=/etc                    \
    	        --localstatedir=/var                 \
    	        --with-console-auth-dir=/run/console \
    	        --docdir=/usr/share/doc/${PKG_NAME}-${PKG_VERSION} &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	systemctl start rescue.target
	make $MAKE_PARALLEL install
	
	mv -v /usr/lib/libdbus-1.so.* /lib
	ln -sfv ../../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so
	
	cat > /etc/dbus-1/session-local.conf << "EOF"
<!DOCTYPE busconfig PUBLIC
 "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>

  <!-- Search for .service files in /usr/local -->
  <servicedir>/usr/local/share/dbus-1/services</servicedir>

</busconfig>
EOF
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
