#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="sudo"
PKG_VERSION="1.8.14p3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
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
    	        --with-passprompt="[sudo] password for %p: " &&
    make $MAKE_PARALLEL
}

function check() {
    env LC_ALL=C make $MAKE_PARALLEL check 2>&1 | tee ../make-check.log
    grep failed ../make-check.log
}

function instal() {
    make $MAKE_PARALLEL install &&
	ln -sfv libsudo_util.so.0.0.0 /usr/lib/sudo/libsudo_util.so.0
	
	cat > /etc/pam.d/sudo << "EOF"
# Begin /etc/pam.d/sudo

# include the default auth settings
auth      include     system-auth

# include the default account settings
account   include     system-account

# Set default environment variables for the service user
session   required    pam_env.so

# include system session defaults
session   include     system-session

# End /etc/pam.d/sudo
EOF
chmod 644 /etc/pam.d/sudo
}

function clean() {
    rm -rf "${SRC_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
