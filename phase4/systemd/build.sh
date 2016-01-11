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
    patch -Np1 -i ../systemd-224-compat-1.patch
    
    sed -e 's:test/udev-test.pl ::g'  \
	-e 's:test-copy$(EXEEXT) ::g' \
	-i Makefile.am
	
    cc_cv_CFLAGS__flto=no              \
    ./configure --prefix=/usr          \
		--sysconfdir=/etc      \
		--localstatedir=/var   \
		--with-rootprefix=     \
		--with-rootlibdir=/lib \
		--enable-split-usr     \
		--disable-firstboot    \
		--disable-ldconfig     \
		--disable-sysusers     \
		--without-python       \
		--docdir=/usr/share/doc/systemd-${PKG_VERSION} &&
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL -k check
}

function instal() {
    systemctl start rescue.target
    make $MAKE_PARALLEL install
    
    mv -v /usr/lib/libnss_{myhostname,mymachines,resolve}.so.2 /lib
    rm -rfv /usr/lib/rpm
    sed -i "s:0775 root lock:0755 root root:g" /usr/lib/tmpfiles.d/legacy.conf
    
    cat >> /etc/pam.d/system-session << "EOF"
# Begin Systemd addition
    
session   required    pam_loginuid.so
session   optional    pam_systemd.so

# End Systemd addition
EOF

    cat > /etc/pam.d/systemd-user << "EOF"
# Begin /etc/pam.d/systemd-user

account  required pam_access.so
account  include  system-account

session  required pam_env.so
session  required pam_limits.so
session  include  system-session

auth     required pam_deny.so
password required pam_deny.so

# End /etc/pam.d/systemd-user
EOF
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean