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
    cat > plasma-5.5.3.md5 << "EOF"
17272fb4160f3a1a5c2abd72cf140a07  kde-cli-tools-5.5.3.tar.xz
023d3107154042f51e3b762c1605520a  kdecoration-5.5.3.tar.xz
6a40b0d2e43b5338156ae35bdecb8bfa  kwayland-5.5.3.tar.xz
a1b180699d229ca32dcfbba001730aa7  libkscreen-5.5.3.tar.xz
faa47a9ed2ff8bde18a1a3af7431a120  libksysguard-5.5.3.tar.xz
1b5ce90bfc3ca40a50195fa75b811e70  breeze-5.5.3.tar.xz
45c96d645c27cd87e851a6e5448e57f4  breeze-gtk-5.5.3.tar.xz
e8459dd31a20a10298c61db6290b0d44  kscreenlocker-5.5.3.tar.xz
0a0c455360e4aa5af96660e20f1c13fc  oxygen-5.5.3.tar.xz
3677c77cea0db406d2445c7e43753a27  khelpcenter-5.5.3.tar.xz
2d01703aac425799cac01e59b76aaa57  kinfocenter-5.5.3.tar.xz
167aedd644053d010f02daecf748b9f6  ksysguard-5.5.3.tar.xz
672d6e03fe621b09b70de16b277d790e  kwin-5.5.3.tar.xz
6e15c10bc83889917d9471318ff3e6f7  systemsettings-5.5.3.tar.xz
1a8c83d8308c4aa86c29dc9d3c5d4cdf  plasma-workspace-5.5.3.tar.xz
60a8f0b9133651b3e6d8f8bc4cd3236c  bluedevil-5.5.3.tar.xz
c40b3062286ab9378c1f2131d0140bff  kde-gtk-config-5.5.3.tar.xz
f35d58f740037f393470ec2390642af1  khotkeys-5.5.3.tar.xz
5faa6dca67930e2b03dee3ab0c5443a9  kmenuedit-5.5.3.tar.xz
34756b46f8e5172a95122e184ce0074b  kscreen-5.5.3.tar.xz
801e55f83760deccabb58e10161d4c46  kwallet-pam-5.5.3.tar.xz
683c0921a52373d17bd19c3c06314dc9  kwayland-integration-5.5.3.tar.xz
207040832d0a2878b0ce5dd41c8d2888  kwrited-5.5.3.tar.xz
cc4811e0e54c16279c934cd2e5c0ea2b  milou-5.5.3.tar.xz
ef1c6011cb407516dff8380893617384  plasma-nm-5.5.3.tar.xz
34bf67146947fb28dd6527ca8bd5f673  plasma-pa-5.5.3.tar.xz
24cc446c50e04ee463a85b2e3ee74182  plasma-workspace-wallpapers-5.5.3.tar.xz
4fb0b176c506e259ca6e3613419ceaa2  polkit-kde-agent-1-5.5.3.tar.xz
aecacfed1e19caae0785f79bfc3bd395  powerdevil-5.5.3.tar.xz
ed01bcf7d3ad8a8e398d8d9ee489e971  plasma-desktop-5.5.3.tar.xz
50398a83ab91afc4eb2cc0793e2e8ea4  kdeplasma-addons-5.5.3.tar.xz
5a3d42cc596554f231795e1c3b653e7d  kgamma5-5.5.3.tar.xz
254dab24a6d868ffd9892a580e011d51  ksshaskpass-5.5.3.tar.xz
56ef7525e72457deed301d947a2cb4cd  plasma-mediacenter-5.5.3.tar.xz
4123319b6917cb899bfaa2c78bb2bb56  plasma-sdk-5.5.3.tar.xz
87a4fa84da38747588fdbb30f8796967  sddm-kcm-5.5.3.tar.xz
99c9e12c5e5a84041e1bd1729e420111  user-manager-5.5.3.tar.xz
95bbda7a85501c1c9b4167fbd458b430  discover-5.5.3.tar.xz
EOF
}

function check() {
	wget -r -c -nH --cut-dirs=3 -A '*.xz' -np http://download.kde.org/stable/plasma/5.5.3/
	
	md5sum -c plasma-5.5.3.md5
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

			case $srcdir in
				kwayland-5.5.3 )
					OPTS="-DECM_MKSPECS_INSTALL_DIR=$KF5_PREFIX/share/mkspecs/modules";;
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

	done < plasma-5.5.3.md5

	cd $KF5_PREFIX/share/plasma/plasmoids
	for j in $(find -name \*.js); do
		as_root ln -sfv ../code/$(basename $j) $(dirname $j)/../ui/
	done
}

prepare;check;build;
