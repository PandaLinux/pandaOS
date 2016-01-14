#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

function build() {    
    cat > /etc/profile.d/xorg.sh << "EOF"
XORG_PREFIX="/usr"
XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"
export XORG_PREFIX XORG_CONFIG
EOF
    chmod 644 /etc/profile.d/xorg.sh        
}

build;