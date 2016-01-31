#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="Linux-PAM"
PKG_VERSION="1.2.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
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
	./configure --prefix=/usr 		\
    	        --sysconfdir=/etc 	\
    	        --libdir=/usr/lib 	\
    	        --enable-securedir=/lib/security &&
	make $MAKE_PARALLEL
	
	install -v -dm755 /etc/pam.d &&
	cat > /etc/pam.d/other << "EOF"
auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so
EOF
}

function check() {
	make $MAKE_PARALLEL check
}

function instal() {
	rm -rfv /etc/pam.d
	
	make $MAKE_PARALLEL install &&
	chmod -v 4755 /sbin/unix_chkpwd &&

	for file in pam pam_misc pamc
	do
		mv -v /usr/lib/lib${file}.so.* /lib &&
		ln -sfv ../../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
	done
	
	install -v -dm755 /etc/pam.d
	cat > /etc/pam.d/system-account << "EOF"
# Begin /etc/pam.d/system-account

account   required    pam_unix.so

# End /etc/pam.d/system-account
EOF

	cat > /etc/pam.d/system-auth << "EOF"
# Begin /etc/pam.d/system-auth

auth      required    pam_unix.so

# End /etc/pam.d/system-auth
EOF

	cat > /etc/pam.d/system-session << "EOF"
# Begin /etc/pam.d/system-session

session   required    pam_unix.so

# End /etc/pam.d/system-session
EOF

	rm /etc/pam.d/system-password &&
	cat > /etc/pam.d/system-password << "EOF"
# Begin /etc/pam.d/system-password

# check new passwords for strength (man pam_cracklib)
password  required    pam_cracklib.so   type=Linux retry=3 difok=5 \
                                        difignore=23 minlen=9 dcredit=1 \
                                        ucredit=1 lcredit=1 ocredit=1 \
                                        dictpath=/lib/cracklib/pw_dict
# use sha512 hash for encryption, use shadow, and use the
# authentication token (chosen password) set by pam_cracklib
# above (or any previous modules)
password  required    pam_unix.so       sha512 shadow use_authtok

# End /etc/pam.d/system-password
EOF

	cat > /etc/pam.d/other << "EOF"
# Begin /etc/pam.d/other

auth        required        pam_warn.so
auth        required        pam_deny.so
account     required        pam_warn.so
account     required        pam_deny.so
password    required        pam_warn.so
password    required        pam_deny.so
session     required        pam_warn.so
session     required        pam_deny.so

# End /etc/pam.d/other
EOF
}

function clean() {
    rm -rf "${SRC_DIR}"
    # Re-install shadow
    rm -rf /phase3/shadow/DONE
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
