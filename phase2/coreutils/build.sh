#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="coreutils"
PKG_VERSION="8.25"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../$PKG_NAME-$PKG_VERSION-i18n-2.patch 
    
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr --enable-no-install-program=kill,uptime            
    FORCE_UNSAFE_CONFIGURE=1 make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL NON_ROOT_USERNAME=nobody check-root
    echo "dummy:x:1000:nobody" >> /etc/group
    chown -Rv nobody .
    su nobody -s /bin/bash \
			  -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
    sed -i '/dummy/d' /etc/group
}

function instal() {
    make $MAKE_PARALLEL install
    
    mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
    mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
    mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
    mv -v /usr/bin/chroot /usr/sbin
    mv -v /usr/bin/{head,sleep,nice,test,[} /bin
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}" "$TARBALL"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
