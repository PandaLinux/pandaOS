#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="sddm"
PKG_VERSION="0.13.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SYSTEMD_UNIT_TARBALL="blfs-bootscripts-20150924.tar.bz2"
SYSTEMD_UNIT="blfs-bootscripts-20150924"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "/source/$TARBALL" "$TARBALL"
        ln -sv "/source/$SYSTEMD_UNIT_TARBALL" "$SYSTEMD_UNIT_TARBALL"
    fi
}

function unpack() {
    tar xf ${TARBALL}
    tar xf ${SYSTEMD_UNIT_TARBALL}
}

function build() {
	groupadd -g 64 sddm &&
	useradd  -c "SDDM Daemon" \
    	     -d /var/lib/sddm \
    	     -u 64 -g sddm    \
    	     -s /bin/false sddm
    	     
	sed -e '/UPOWER_SERVICE)/ s:^://:' \
    	-i src/daemon/PowerManager.cpp &&
	sed -e 's/eval exec/& ck-launch-session /' \
    	-i data/scripts/Xsession
    	
	mkdir build &&
	cd    build &&

	cmake -DCMAKE_INSTALL_PREFIX=/usr \
    	  -DCMAKE_BUILD_TYPE=Release  \
    	  -DENABLE_JOURNALD=OFF       \
    	  -DDBUS_CONFIG_FILENAME=sddm_org.freedesktop.DisplayManager.conf \
    	  -Wno-dev .. &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install &&
	install -v -dm755 -o sddm -g sddm /var/lib/sddm
	
	sddm --example-config > /etc/sddm.conf
	sed -e 's/-nolisten tcp//'\
	    -i /etc/sddm.conf
	sed -e 's/\"none\"/\"off\"/' \
	    -i /etc/sddm.conf
	
	cd /phase5/sddm/$SYSTEMD_UNIT
	make $MAKE_PARALLEL install-sddm
	    
	cat > /etc/pam.d/sddm << "EOF"
# Begin /etc/pam.d/sddm

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     include        system-auth

account  include        system-account
password include        system-password

session  required       pam_limits.so
session  include        system-session

# End /etc/pam.d/sddm
EOF

	cat > /etc/pam.d/sddm-autologin << "EOF"
# Begin /etc/pam.d/sddm-autologin

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so

account  include        system-account

password required       pam_deny.so

session  required       pam_limits.so
session  include        system-session

# End /etc/pam.d/sddm-autologin
EOF

	cat > /etc/pam.d/sddm-greeter << "EOF"
# Begin /etc/pam.d/sddm-greeter

auth     required       pam_env.so
auth     required       pam_permit.so

account  required       pam_permit.so
password required       pam_deny.so
session  required       pam_unix.so
-session optional       pam_systemd.so

# End /etc/pam.d/sddm-greeter
EOF

	cp -v /etc/inittab{,-orig} &&
	sed -i '/initdefault/ s/3/5/' /etc/inittab
	echo "source /etc/profile.d/dircolors.sh" >> /etc/bashrc
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean;
