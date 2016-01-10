#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

function build() {
    cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

# End /etc/fstab
EOF

echo "$FILE_SYSTEM    /            ext4    defaults            1     1" >> /etc/fstab
}

build;