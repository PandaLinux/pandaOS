#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="coreutils"
PKG_VERSION="8.24"

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
    patch -Np1 -i ../coreutils-8.24-i18n-1.patch 
    sed -i '/tests\/misc\/sort.pl/ d' Makefile.in
    
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr --enable-no-install-program=kill,uptime            
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL NON_ROOT_USERNAME=nobody check-root
    echo "dummy:x:1000:nobody" >> /etc/group
    chown -Rv nobody .
    su nobody -s /bin/bash \
	      -c "PATH=$PATH make $MAKE_PARALLEL RUN_EXPENSIVE_TESTS=yes check"
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
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
