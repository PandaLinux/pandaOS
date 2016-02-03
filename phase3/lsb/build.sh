#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

function build() {
    cat > /etc/os-release << "EOF"
NAME="Panda"
VERSION="1.0"
ID=panda
ID_LIKE=debian
PRETTY_NAME="Panda Linux"
VERSION_ID="1.0"
HOME_URL="https://github.com/PandaLinux/pandaOS"
BUG_REPORT_URL="https://github.com/PandaLinux/pandaOS/issues"
EOF
    
    cat > /etc/lsb-release << "EOF"
DISTRIB_ID=Panda
DISTRIB_RELEASE=1.0
DISTRIB_CODENAME=black
DISTRIB_DESCRIPTION="Panda Linux"
EOF
}

build;
