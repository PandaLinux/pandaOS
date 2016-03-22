#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

function build() {
    cat > /etc/systemd/network/10-static-eth0.network << "EOF"
[Match]
Name=eth0

[Network]
Address=192.168.0.2/24
Gateway=192.168.0.1
DNS=192.168.0.1
EOF

    cat > /etc/systemd/network/10-dhcp-eth0.network << "EOF"
[Match]
Name=eth0

[Network]
DHCP=yes
EOF

    cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

nameserver 8.8.8.8
nameserver 8.8.4.4

# End /etc/resolv.conf
EOF
    
    echo "panda" > /etc/hostname
        
    cat > /etc/hosts << "EOF"
# Begin /etc/hosts (network card version)

127.0.0.1 localhost
::1       localhost

# End /etc/hosts (network card version)
EOF
}

build;
