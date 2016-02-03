#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="glibc"
PKG_VERSION="2.22"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

TARBALL_TZ="tzdata2015f.tar.gz"
SRC_DIR_TZ="tzdata2015f"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "/source/$TARBALL" "$TARBALL"
        ln -sv "/source/$TARBALL_TZ" "$TARBALL_TZ"
    fi
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../glibc-2.22-fhs-1.patch
    
    mkdir "${BUILD_DIR}" &&
    cd "${BUILD_DIR}" &&
    ../configure --prefix=/usr          \
				 --disable-profile      \
				 --enable-kernel=2.6.32 \
				 --enable-obsolete-rpc
    make $MAKE_PARALLEL
}

function check() {
    make $MAKE_PARALLEL check
}

function instal() {
    touch /etc/ld.so.conf
    make $MAKE_PARALLEL install
    
    cp -v ../nscd/nscd.conf /etc/nscd.conf
    mkdir -pv /var/cache/nscd
    
    install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
    install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service
    
    mkdir -pv /usr/lib/locale
    localedef -i en_US -f ISO-8859-1 en_US
    localedef -i en_US -f UTF-8 en_US.UTF-8
    
    cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns myhostname
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

    tar xf "/phase2/glibc/${TARBALL_TZ}"

    ZONEINFO=/usr/share/zoneinfo
    mkdir -pv $ZONEINFO/{posix,right}

    for tz in etcetera southamerica northamerica europe africa antarctica  \
	      asia australasia backward pacificnew systemv; do
	zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
	zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
	zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
    done

    cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
    zic -d $ZONEINFO -p America/New_York
    unset ZONEINFO

    ln -sfv /usr/share/zoneinfo/America/New_York /etc/localtime
    
    cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib

EOF

    cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
    mkdir -pv /etc/ld.so.conf.d
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
