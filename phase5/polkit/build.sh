#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="polkit"
PKG_VERSION="0.113"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	groupadd -fg 27 polkitd &&
	useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
    	    -g polkitd -s /bin/false polkitd
    	    
	./configure --prefix=/usr        			\
				--sysconfdir=/etc    			\
				--localstatedir=/var 			\
				--enable-libsystemd-login=yes 	\
				--with-authfw=shadow			\
				--disable-static     			&&
	make $MAKE_PARALLEL
}

function check() {
	make $MAKE_PARALLEL check
}

function instal() {
	make $MAKE_PARALLEL install
	
	cat > /etc/pam.d/polkit-1 << "EOF"
# Begin /etc/pam.d/polkit-1

auth     include        system-auth
account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/polkit-1
EOF
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
