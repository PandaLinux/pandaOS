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
    cat > plasma-5.6.0.md5 << "EOF"
9939aaabbe048c82a0d371b93356bb1b  kde-cli-tools-5.6.0.tar.xz
c21c5d17d3acf80568950daf6bcdd1fe  kdecoration-5.6.0.tar.xz
464f49413bc8e0e61eeaad6520c39473  kwayland-5.6.0.tar.xz
78424f1562b2aea71ec5b384ef01c3ae  libkscreen-5.6.0.tar.xz
d2297d1a4996d5ac855a5d98cf1d9581  libksysguard-5.6.0.tar.xz
2617b12844e97ad41d67fa238b725d90  breeze-5.6.0.tar.xz
e46e9d3b90cf19b20afb4ec6789131e0  breeze-gtk-5.6.0.tar.xz
958fa3cb8fa156c40bc20cb46767a5fa  kscreenlocker-5.6.0.tar.xz
3e2cf4a6b4ff58769249525686ecb990  oxygen-5.6.0.tar.xz
1c37b094bd3273912acebae2f52dcbba  khelpcenter-5.6.0.tar.xz
a9bc4c9ba6bee7873e8f2a2396fcc5c5  kinfocenter-5.6.0.tar.xz
690d154abd0458120511e92b1f602bcb  ksysguard-5.6.0.tar.xz
1add44b5f04bf60eb98dd7432bd45a56  kwin-5.6.0.tar.xz
34deac7edd5abdafaf37279501a27ae8  systemsettings-5.6.0.tar.xz
59a5f026b88158c3a1675fff52846cbf  plasma-workspace-5.6.0.tar.xz
76886f822f4866b5e6cd09ad0b294b5a  bluedevil-5.6.0.tar.xz
62537a68d222f2a5a114d0f00b6d9664  kde-gtk-config-5.6.0.tar.xz
129f356ddcfd7a4366006e1f5598eda5  khotkeys-5.6.0.tar.xz
c5a37c45b9a2cd39b287e333910b170d  kmenuedit-5.6.0.tar.xz
5a43b4ca376cf5321294ae6a02e84416  kscreen-5.6.0.tar.xz
4fd13634ba67aca79839cb1940302613  kwallet-pam-5.6.0.tar.xz
d0a617777fc8793e685e0ea1cba5eda9  kwayland-integration-5.6.0.tar.xz
cb7831be19e51c6d4ec2f62024726998  kwrited-5.6.0.tar.xz
fba2776f99c139bb64c731f092687b72  milou-5.6.0.tar.xz
ec0df73abdcb30aa13737af704130ca1  plasma-nm-5.6.0.tar.xz
f9beabe2a235c1c59e6d44c2f09c0bd1  plasma-pa-5.6.0.tar.xz
751c26021ad463215d1e57cbf8f976f5  plasma-workspace-wallpapers-5.6.0.tar.xz
b62322564a3c70330021c9b1bedf93af  polkit-kde-agent-1-5.6.0.tar.xz
f3dfc7affd4492731cab7d0ce293dd5b  powerdevil-5.6.0.tar.xz
459a7ee12a9e404164d5843b4c22500a  plasma-desktop-5.6.0.tar.xz
9e1892505d9277a650f5de2a991dfb10  kdeplasma-addons-5.6.0.tar.xz
8ac30fe02721cc355a696e8966de85d1  kgamma5-5.6.0.tar.xz
df606fc93c1fa06407d15230dacc67e7  ksshaskpass-5.6.0.tar.xz
351aba4bf5d8932232d04dfaf5165f3e  plasma-mediacenter-5.6.0.tar.xz
7405dabf94dbafaae354b188bc6dfcb7  plasma-sdk-5.6.0.tar.xz
810f4e9ac4d0b6b6cbd3bfa315742b35  sddm-kcm-5.6.0.tar.xz
6df0619e5446a52111709181878b3717  user-manager-5.6.0.tar.xz
afad2be536e324dfbea25af96c2fe9b4  discover-5.6.0.tar.xz
#ea4209e98097b42423859295be795e55  breeze-grub-5.6.0.tar.xz
#ba767671eb7741405215f9a7e4b05ea5  breeze-plymouth-5.6.0.tar.xz
116551aa32f5929648abf5e298385c83  kactivitymanagerd-5.6.0.tar.xz
c26be1b6ed15604accf8f725c068279a  plasma-integration-5.6.0.tar.xz
2aacc6c4f92ee3c2327d01df40b72269  simplesystray-5.6.0.tar.xz
EOF
}

function check() {
	wget -r -c -nH --cut-dirs=3 -A '*.xz' -np http://download.kde.org/stable/plasma/5.6.0/	
	md5sum -c plasma-5.6.0.md5
}

function build() {
	set -e
	while read -r line; do

		# Get the file name, ignoring comments and blank lines
		if $(echo $line | grep -E -q '^ *$|^#' ); then continue; fi
		file=$(echo $line | cut -d" " -f2)

		pkg=$(echo $file|sed 's|^.*/||')          # Remove directory
		packagedir=$(echo $pkg|sed 's|\.tar.*||') # Package directory

		tar -xf $file
		pushd $packagedir

			mkdir build
			cd    build

			OPTS=""

			case $packagedir in
				kwayland-5.6.0 )
					OPTS="-DECM_MKSPECS_INSTALL_DIR=$KF5_PREFIX/share/mkspecs/modules" ;;
			esac

			cmake 	-DCMAKE_INSTALL_PREFIX=$KF5_PREFIX \
					-DCMAKE_BUILD_TYPE=Release         \
					-DLIB_INSTALL_DIR=lib              \
					-DBUILD_TESTING=OFF                \
					$OPTS                              \
					-Wno-dev ..  &&

			make $MAKE_PARALLEL
			as_root make $MAKE_PARALLEL install
		popd

		rm -rf $packagedir
		as_root /sbin/ldconfig

	done < plasma-5.6.0.md5

	cd $KF5_PREFIX/share/plasma/plasmoids

	for j in $(find -name \*.js); do
		as_root ln -sfv ../code/$(basename $j) $(dirname $j)/../ui/
	done
	set +e
}

prepare;check;build;
