#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

function build() {
    cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF
}

build;