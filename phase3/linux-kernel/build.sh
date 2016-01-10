#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="linux"
PKG_VERSION="4.2"

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
    make $MAKE_PARALLEL mrproper
    make $MAKE_PARALLEL defconfig
    make $MAKE_PARALLEL
}

function check() {
    echo "Nothing to be done here."
}

function instal() {
    make $MAKE_PARALLEL modules_install
    cp -v arch/x86/boot/bzImage /boot/$VM_LINUZ
    cp -v System.map /boot/$SYSTEM_MAP
    cp -v .config /boot/$CONFIG_BACKUP
    install -d /usr/share/doc/linux-4.2
    cp -r Documentation/* /usr/share/doc/linux-4.2
    
    install -v -m755 -d /etc/modprobe.d
    cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean