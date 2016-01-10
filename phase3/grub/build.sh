#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

function build() {
    mkdir -pv /boot/grub
    cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
EOF

NUMBER=$(echo $FILE_SYSTEM | tr -dc '0-9')

echo "set default=0" >> /boot/grub/grub.cfg
echo "set timeout=10" >> /boot/grub/grub.cfg
echo "insmod ext4" >> /boot/grub/grub.cfg
echo "set root=(hd0,$NUMBER)" >> /boot/grub/grub.cfg
echo "menuentry 'GNU/Linux, Panda Linux' {
	  linux   /boot/$VM_LINUZ root=$FILE_SYSTEM ro
      }" >> /boot/grub/grub.cfg
}

build;