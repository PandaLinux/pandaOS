#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

function build() {
    cat > /etc/adjtime << "EOF"
0.0 0 0.0
0
LOCAL
EOF
}

build;