#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

function as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

export -f as_root

function prepare() {
    cat > lib-7.7.md5 << "EOF"
c5ba432dd1514d858053ffe9f4737dd8  xtrans-1.3.5.tar.bz2
2e36b73f8a42143142dda8129f02e4e0  libX11-1.6.3.tar.bz2
52df7c4c1f0badd9f82ab124fb32eb97  libXext-1.3.3.tar.bz2
d79d9fe2aa55eb0f69b1a4351e1368f7  libFS-1.0.7.tar.bz2
addfb1e897ca8079531669c7c7711726  libICE-1.0.9.tar.bz2
499a7773c65aba513609fe651853c5f3  libSM-1.2.2.tar.bz2
7a773b16165e39e938650bcc9027c1d5  libXScrnSaver-1.2.2.tar.bz2
8f5b5576fbabba29a05f3ca2226f74d3  libXt-1.1.5.tar.bz2
41d92ab627dfa06568076043f3e089e4  libXmu-1.1.2.tar.bz2
769ee12a43611cdebd38094eaf83f3f0  libXpm-3.5.11.tar.bz2
e5e06eb14a608b58746bdd1c0bd7b8e3  libXaw-1.0.13.tar.bz2
b985b85f8b9386c85ddcfe1073906b4d  libXfixes-5.0.1.tar.bz2
f7a218dcbf6f0848599c6c36fc65c51a  libXcomposite-0.4.4.tar.bz2
5db92962b124ca3a8147daae4adbd622  libXrender-0.9.9.tar.bz2
1e7c17afbbce83e2215917047c57d1b3  libXcursor-1.1.14.tar.bz2
0cf292de2a9fa2e9a939aefde68fd34f  libXdamage-1.1.4.tar.bz2
0920924c3a9ebc1265517bdd2f9fde50  libfontenc-1.1.3.tar.bz2
96f76ba94b4c909230bac1e2dcd551c4  libXfont-1.5.1.tar.bz2
331b3a2a3a1a78b5b44cfbd43f86fcfe  libXft-2.3.2.tar.bz2
510e555ecfffa8d2298a0f42b725e563  libXi-1.7.6.tar.bz2
9336dc46ae3bf5f81c247f7131461efd  libXinerama-1.1.3.tar.bz2
309762867e41c6fd813da880d8a1bc93  libXrandr-1.5.0.tar.bz2
45ef29206a6b58254c81bea28ec6c95f  libXres-1.0.7.tar.bz2
25c6b366ac3dc7a12c5d79816ce96a59  libXtst-1.2.2.tar.bz2
e0af49d7d758b990e6fef629722d4aca  libXv-1.0.10.tar.bz2
eba6b738ed5fdcd8f4203d7c8a470c79  libXvMC-1.0.9.tar.bz2
d7dd9b9df336b7dd4028b6b56542ff2c  libXxf86dga-1.1.4.tar.bz2
298b8fff82df17304dfdb5fe4066fe3a  libXxf86vm-1.1.4.tar.bz2
ba983eba5a9f05d152a0725b8e863151  libdmx-1.1.3.tar.bz2
4a4cfeaf24dab1b991903455d6d7d404  libxkbfile-1.0.9.tar.bz2
66662e76899112c0f99e22f2fc775a7e  libxshmfence-1.2.tar.bz2
EOF

	mkdir lib
}

function check() {
	grep -v '^#' ../lib-7.7.md5 | awk '{print $2}' | wget -i- -c \
	     -B http://xorg.freedesktop.org/archive/individual/lib/ &&
	md5sum -c ../lib-7.7.md5
}

function build() {
	for package in $(grep -v '^#' ../lib-7.7.md5 | awk '{print $2}')
	do
		packagedir=${package%.tar.bz2}
		tar -xf $package
		pushd $packagedir
			case $packagedir in
				libXfont-[0-9]* )
					./configure $XORG_CONFIG --disable-devel-docs;;
					
			    libXt-[0-9]* )
			      ./configure $XORG_CONFIG \
            			      --with-appdefaultdir=/etc/X11/app-defaults;;
            			      
			    * )
			      ./configure $XORG_CONFIG;;
			esac
			make $MAKE_PARALLEL
			make $MAKE_PARALLEL check 2>&1 | tee ../$packagedir-make_check.log
			as_root make $MAKE_PARALLEL install
		popd
		rm -rf $packagedir
		as_root /sbin/ldconfig
	done
}

prepare;pushd lib;check;build;popd
