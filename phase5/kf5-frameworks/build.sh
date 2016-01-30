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
    cat > frameworks-5.18.0.md5 << "EOF"
bcbcd88f73333da0ee5fb54f8e5242f1  extra-cmake-modules-5.18.0.tar.xz
55422b499a3ebc5743df167b26685f3c  attica-5.18.0.tar.xz
5ce0af21d551fffff36bcf95c2afcfb5  kapidox-5.18.0.tar.xz
5e6da520d4910dad8a03dde2d5b4c2d2  karchive-5.18.0.tar.xz
acc299e8013b8fcb0e00d42715570ef3  kcodecs-5.18.0.tar.xz
061b6eedc15239368e5bd60645b99a50  kconfig-5.18.0.tar.xz
978c394967cbf1677a6adf75ddc807fe  kcoreaddons-5.18.0.tar.xz
075272719a8d04a10f9c8d202fc6e5b3  kdbusaddons-5.18.0.tar.xz
9b5d3628895cc6f09adf47856fc392ab  kdnssd-5.18.0.tar.xz
d8a16a939ca84b04ec31b4b57a979bd7  kguiaddons-5.18.0.tar.xz
cbea420a939fedd13f6d4c0b9279b758  ki18n-5.18.0.tar.xz
5ea44a48edb80307ad19d0fa6dac6384  kidletime-5.18.0.tar.xz
023449bdce8c1dd8241bafafed7c006a  kimageformats-5.18.0.tar.xz
a9bbb20d5e0df44afd95f552fd9a116b  kitemmodels-5.18.0.tar.xz
bb909fcb3e98cfb55082e48d2ca6d669  kitemviews-5.18.0.tar.xz
57803cd443bc0a1d1c957c71f08e7899  kplotting-5.18.0.tar.xz
13f7cdb060d00905021f63ce24705219  kwidgetsaddons-5.18.0.tar.xz
c1a5c3dee013ee189d3279a9e58189e3  kwindowsystem-5.18.0.tar.xz
5bd6cc807ce152c241aa33a16339710a  networkmanager-qt-5.18.0.tar.xz
783ceff0aed29a57235fb05abca41b6a  solid-5.18.0.tar.xz
8fb3c2fac12e7c2671c3318f41bc4161  sonnet-5.18.0.tar.xz
4abcb4004837be65830b47fd8f2bc6a3  threadweaver-5.18.0.tar.xz
2732f1ad8224a63fe7a89e7471b6c29c  kauth-5.18.0.tar.xz
af520088daa15b0ead9fe6077059359b  kcompletion-5.18.0.tar.xz
6503c2c7b8df59be593f73df87a5efcd  kcrash-5.18.0.tar.xz
75f85023291440e81cf2fc70e412cd18  kdoctools-5.18.0.tar.xz
03ff4be4bbb45979c34419a5d05d7cbb  kpty-5.18.0.tar.xz
a417abc36106520833a6a9b240b874e3  kunitconversion-5.18.0.tar.xz
ed946b78eb19c3fe1458ec78606d089c  kconfigwidgets-5.18.0.tar.xz
62bb2ad7e0e98047431274f1cfc66b57  kglobalaccel-5.18.0.tar.xz
5c4a2ac94e8d1b8f47286eaca83cab0c  kpackage-5.18.0.tar.xz
8eafea43f9bb4f5e01767df8ebccdc49  kservice-5.18.0.tar.xz
1c9505a8e516eb01e69049c032772ad8  kdesu-5.18.0.tar.xz
52afdc09c21c786acbe863e3f64334a3  kemoticons-5.18.0.tar.xz
7de83ced56231a852956ec41815c22e0  kiconthemes-5.18.0.tar.xz
fb8c4e9d823b3a8ec084f8c710909147  kjobwidgets-5.18.0.tar.xz
d7d25c868bad8fb567877924d33770df  knotifications-5.18.0.tar.xz
2cc0ee770de0714cdec198c23246f28d  ktextwidgets-5.18.0.tar.xz
f8223c50d9a34f7017edb86bf87341a8  kwallet-5.18.0.tar.xz
591c050cb901b6484448d2c40d7f0e69  kxmlgui-5.18.0.tar.xz
66b54cef3432c2a36db1dba8916add93  kbookmarks-5.18.0.tar.xz
3544f70348993c7fe086854214e48aee  kio-5.18.0.tar.xz
462e0f48f591d3b1d5c1091a3f5327ae  kdeclarative-5.18.0.tar.xz
71a5229d1c5648c4cb218a042c1fa018  kcmutils-5.18.0.tar.xz
82116c14ad16b43ef2fa800b5c48edec  frameworkintegration-5.18.0.tar.xz
bbf6f2743ffc9ffba7dcb151e7b579e0  kinit-5.18.0.tar.xz
95cf2acca601bf7d80657d6bb327095b  knewstuff-5.18.0.tar.xz
ebb657138d4d1a8f73dd0f0656d24450  knotifyconfig-5.18.0.tar.xz
4d465788cbc34707a64bdebd9aa978bf  kparts-5.18.0.tar.xz
984c74b7ef242703990caa8b2a0b187e  kactivities-5.18.0.tar.xz
480a09bea54f2a052a883352a7902e08  kded-5.18.0.tar.xz
#1b4757582112bf05fdc85f4ad8bdeca9  kdewebkit-5.18.0.tar.xz
6c42319bacb47bc416fde04f57485a72  ktexteditor-5.18.0.tar.xz
9e03c83e412caf74b42949393665b533  kdesignerplugin-5.18.0.tar.xz
45573350b9f2257a80beaa81bb1b1115  plasma-framework-5.18.0.tar.xz
79a4865a6b4c60f180511c35fa1b664e  modemmanager-qt-5.18.0.tar.xz
88a5ff9ae7d7ea0a87b26312658ba86f  kpeople-5.18.0.tar.xz
6bbcff1866ff9165dbd0a9b3fd53e763  kxmlrpcclient-5.18.0.tar.xz
76a2a9ed1dbac45cf4cf50297ba02472  bluez-qt-5.18.0.tar.xz
62d98eec25d779bad419752793ff88e0  kfilemetadata-5.18.0.tar.xz
90894895db301b7ab069d272a5b99bdc  baloo-5.18.0.tar.xz
6663ffe69176c43ae4a4d6aab6f3dc67  breeze-icons-5.18.0.tar.xz
af3ffb2b0e1f978d13fbdf88da29bb89  oxygen-icons5-5.18.0.tar.xz
332bd1a8e3d131a5cd7774f3d1092bc3  portingAids/kjs-5.18.0.tar.xz
ea647553f54e7d25e60cecaa8e3b30ad  portingAids/kdelibs4support-5.18.0.tar.xz
6c5f6efdd6f69193cfce5c9c57cfeabb  portingAids/khtml-5.18.0.tar.xz
a3d27a96247c55ea52df34f1cbbc1b2a  portingAids/kjsembed-5.18.0.tar.xz
2f584b440f68e1f4d97377fd6f9ee930  portingAids/kmediaplayer-5.18.0.tar.xz
c624dbad90370ed208f728811e2eda91  portingAids/kross-5.18.0.tar.xz
51f616e04e7e77e0d4f526b1215b33ac  portingAids/krunner-5.18.0.tar.xz
EOF
}

function check() {
	wget -r -c -nH --cut-dirs=3 -A '*.xz' -np http://download.kde.org/stable/frameworks/5.18/
	
	md5sum -c frameworks-5.18.0.md5
}

function build() {
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

	done < frameworks-5.18.0.md5
}

prepare;check;build;
