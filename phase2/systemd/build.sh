#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="systemd"
PKG_VERSION="224"

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
    cat > config.cache << "EOF"
KILL=/bin/kill
MOUNT_PATH=/bin/mount
UMOUNT_PATH=/bin/umount
HAVE_BLKID=1
BLKID_LIBS="-lblkid"
BLKID_CFLAGS="-I/tools/include/blkid"
HAVE_LIBMOUNT=1
MOUNT_LIBS="-lmount"
MOUNT_CFLAGS="-I/tools/include/libmount"
cc_cv_CFLAGS__flto=no
EOF

    sed -i "s:blkid/::" $(grep -rl "blkid/blkid.h")
    patch -Np1 -i ../systemd-224-compat-3.patch    
    sed -e 's:test/udev-test.pl ::g'  \
    -e 's:test-copy$(EXEEXT) ::g' \
    -i Makefile.in
    
    ./configure --prefix=/usr                                           \
		--sysconfdir=/etc                                       \
		--localstatedir=/var                                    \
		--config-cache                                          \
		--with-rootprefix=                                      \
		--with-rootlibdir=/lib                                  \
		--enable-split-usr                                      \
		--disable-firstboot                                     \
		--disable-ldconfig                                      \
		--disable-sysusers                                      \
		--without-python                                        \
		--docdir=/usr/share/doc/systemd-224                     \
		--with-dbuspolicydir=/etc/dbus-1/system.d               \
		--with-dbussessionservicedir=/usr/share/dbus-1/services \
		--with-dbussystemservicedir=/usr/share/dbus-1/system-services
    make $MAKE_PARALLEL LIBRARY_PATH=/tools/lib
}

function check() {
    sed -i "s:minix:ext4:g" src/test/test-path-util.c
    make $MAKE_PARALLEL LD_LIBRARY_PATH=/tools/lib -k check
}

function instal() {
    make $MAKE_PARALLEL LD_LIBRARY_PATH=/tools/lib install
    
    mv -v /usr/lib/libnss_{myhostname,mymachines,resolve}.so.2 /lib
    rm -rfv /usr/lib/rpm
    
    for tool in runlevel reboot shutdown poweroff halt telinit; do
	ln -sfv ../../../bin/systemctl /sbin/${tool}
    done
    ln -sfv ../../../lib/systemd/systemd /sbin/init
    
    sed -i "s:0775 root lock:0755 root root:g" /usr/lib/tmpfiles.d/legacy.conf
    systemd-machine-id-setup    
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;instal;[[ $MAKE_CHECK = TRUE ]] && check;popd;clean