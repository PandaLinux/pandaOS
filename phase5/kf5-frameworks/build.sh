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
    cat > frameworks-5.20.0.md5 << "EOF"
1b2e1a6416f47c3d8b5e1a8bc4680570  extra-cmake-modules-5.20.0.tar.xz
217141216fa45f79d7373cadd3e3c27c  attica-5.20.0.tar.xz
7352555cce189863890be9ef8166f665  kapidox-5.20.0.tar.xz
67f61e0ad2ac41e12597a000a436398b  karchive-5.20.0.tar.xz
55582ae9c6e021a23bb7c0f25329ea04  kcodecs-5.20.0.tar.xz
1ee3cc6ae99928adf7fa93204d89a0ce  kconfig-5.20.0.tar.xz
ae26f693d3c60660b7c593d2f9d293bf  kcoreaddons-5.20.0.tar.xz
42ec6aa625812307b3710d1d7df517f7  kdbusaddons-5.20.0.tar.xz
ec54202d940f38866b73c550133072a2  kdnssd-5.20.0.tar.xz
b2cfb78436d3bf15d2197a0676d4fe19  kguiaddons-5.20.0.tar.xz
b2c5edb59d6ab4fd78d0bf68cfb631c6  ki18n-5.20.0.tar.xz
ff732995f09a2fa1168968b84d5b69b5  kidletime-5.20.0.tar.xz
72be30ed58c068675af34fc3d6430ad0  kimageformats-5.20.0.tar.xz
9a81d2651bb663b65d5c1671af573a1a  kitemmodels-5.20.0.tar.xz
6ba8ee40baffbaab3ec81439bdff0fe7  kitemviews-5.20.0.tar.xz
5507be20fee8389eca24e1358f1273e3  kplotting-5.20.0.tar.xz
0203c7f7bec440a748e01f24231f3e67  kwidgetsaddons-5.20.0.tar.xz
67e4026752ad7879de67bc7a6e5b55d0  kwindowsystem-5.20.0.tar.xz
f25b6f54c7728fc0fb031f01065014f9  networkmanager-qt-5.20.0.tar.xz
0bcf42d89dc6276dbba3b9f8259d67ab  solid-5.20.0.tar.xz
3e545a92255a92c6899fc8a8f2aa3439  sonnet-5.20.0.tar.xz
32400f7753597da9982c36e4ea8d88bb  threadweaver-5.20.0.tar.xz
fb9c705b84641d62125b878349fcd4db  kauth-5.20.0.tar.xz
9c8f7777dfd9caddbd07dae52d05e613  kcompletion-5.20.0.tar.xz
6eb332c832849358e2b8d895fb871784  kcrash-5.20.0.tar.xz
b4988310d6a97d052a6424ebcf50cfc0  kdoctools-5.20.0.tar.xz
bf119f71086e84e362a78bc5a798efc4  kpty-5.20.0.tar.xz
06ee394eca473a0be5532b75abc1b2ee  kunitconversion-5.20.0.tar.xz
188d0d9cf0a4d865e3efa8bf65004d6d  kconfigwidgets-5.20.0.tar.xz
52f2ea2af7c86aeadc517ef5058c59ef  kglobalaccel-5.20.0.tar.xz
8b49da1df16dc5c440c6b5a9b63fddf6  kpackage-5.20.0.tar.xz
39b08d4a7afff397cb819f6c63de46d6  kservice-5.20.0.tar.xz
bb1af4f2402e4f1efda63e9815022f85  kdesu-5.20.0.tar.xz
8c9fd278223ed58f144ef2a69dbeba75  kemoticons-5.20.0.tar.xz
213a5258476ffc51e77526a31dc909f3  kiconthemes-5.20.0.tar.xz
6b621bbcb82a3fd8f563298136529b29  kjobwidgets-5.20.0.tar.xz
d98489d1ef939d5f4a20a2969b93c68d  knotifications-5.20.0.tar.xz
27ff19e2da61e30b1997121a048c6672  ktextwidgets-5.20.0.tar.xz
8f7404990e60580dd6b707f6a7c390a4  kwallet-5.20.0.tar.xz
0faf3974771268f42db7c1d4f52f3b9c  kxmlgui-5.20.0.tar.xz
bb9a4977c9274119f862bd8fa80b5ff3  kbookmarks-5.20.0.tar.xz
f700e4089783d2420406b5024fef9f65  kio-5.20.0.tar.xz
65178a250ab8694885c7727b824266b2  kdeclarative-5.20.0.tar.xz
917f0d983e9427d6af44f32f8e01977a  kcmutils-5.20.0.tar.xz
cedac6f1740ca905f2c70cd9202b7e5d  frameworkintegration-5.20.0.tar.xz
09ce4488755c84d1184ecea5438e2749  kinit-5.20.0.tar.xz
78b7a63732f76652cc95fed80e138074  knewstuff-5.20.0.tar.xz
79bf2e28b2bdccdcc6a06c7b0bd2651f  knotifyconfig-5.20.0.tar.xz
47e856a1cc7fbc3e9ed9f2326e998586  kparts-5.20.0.tar.xz
7dc889ce8dc8d58fc74270b2462acef7  kactivities-5.20.0.tar.xz
ecaf1a671b4b8a156b5652da4f6d28be  kded-5.20.0.tar.xz
6fbaf96bfe290b7a411aae75febe7513  kdewebkit-5.20.0.tar.xz
4e4cdc9d49dd3a3a865d91ffaec392ba  ktexteditor-5.20.0.tar.xz
09b2d70bc7b505569a5fc9f35bfed3d2  kdesignerplugin-5.20.0.tar.xz
8ad1c95b1d1e9a67910341733cc6bf62  plasma-framework-5.20.0.tar.xz
#02b432683f966a7f56e1ffb90264e88d  modemmanager-qt-5.20.0.tar.xz
99b17824db5e65963b2419094e51f8d7  kpeople-5.20.0.tar.xz
5a3823f2e2a2e808784bb87ba4a39448  kxmlrpcclient-5.20.0.tar.xz
ef9f28cb55851f908e3aa7e5b7198105  bluez-qt-5.20.0.tar.xz
b5f1f4c3313fd854633d2e1b57784d23  kfilemetadata-5.20.0.tar.xz
25b72b7e77588d46f4b8e8098679b04e  baloo-5.20.0.tar.xz
#5b0cbd57e9d2ff7261a5b88fa37f9401  breeze-icons-5.20.0.tar.xz
#989a432e49ba31a6315c72774af15791  oxygen-icons5-5.20.0.tar.xz
fbba353023ee472a93c7335d26d681dd  portingAids/kjs-5.20.0.tar.xz
d7a9c4940be6eca07c8586610e69d586  portingAids/kdelibs4support-5.20.0.tar.xz
351e8754f3d237aa890a845a6c559093  portingAids/khtml-5.20.0.tar.xz
c275c599c65bd710499b02b3ed58e79a  portingAids/kjsembed-5.20.0.tar.xz
a4f35a1b78235e0b047937fbd4953eb0  portingAids/kmediaplayer-5.20.0.tar.xz
ac7a5cd20b06661edf13faad77d4ac89  portingAids/kross-5.20.0.tar.xz
99fb57dba31fbf6378528ec364e1e579  portingAids/krunner-5.20.0.tar.xz
EOF
}

function check() {	
	url=http://download.kde.org/stable/frameworks/5.20/
	wget -c -r -nH --cut-dirs=3 -A '*.xz' -np $url &&
	sed "s:portingAids/::g" frameworks-5.20.0.md5 | md5sum -c -
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

			cmake 	-DCMAKE_INSTALL_PREFIX=$KF5_PREFIX \
					-DCMAKE_PREFIX_PATH=$QT5DIR        \
					-DCMAKE_BUILD_TYPE=Release         \
					-DLIB_INSTALL_DIR=lib              \
					-DBUILD_TESTING=OFF                \
					-Wno-dev ..
			make $MAKE_PARALLEL
			as_root make $MAKE_PARALLEL install
		popd

		rm -rf $packagedir
		as_root /sbin/ldconfig

	done < frameworks-5.20.0.md5
	set +e
	
	mv -v /opt/kf5 /opt/kf5-5.20.0
	ln -sfvn kf5-5.20.0 /opt/kf5
}

prepare;check;build;popd;
