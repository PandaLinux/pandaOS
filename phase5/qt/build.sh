#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e

PKG_NAME="qt"
PKG_VERSION="5.5.1"

TARBALL="${PKG_NAME}-everywhere-opensource-src-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-everywhere-opensource-src-${PKG_VERSION}"

function prepare() {
    ln -sv "/source/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	./configure -prefix         $QT5PREFIX \
	            -sysconfdir     /etc/xdg   \
    	        -confirm-license           \
    	        -opensource                \
    	        -dbus-linked               \
    	        -openssl-linked            \
    	        -system-harfbuzz           \
    	        -system-sqlite             \
    	        -nomake examples           \
    	        -no-rpath                  \
    	        -optimized-qmake           \
    	        -skip qtwebengine		   \
    	        -verbose				   &&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	make $MAKE_PARALLEL install
	find $QT5PREFIX/lib/pkgconfig -name "*.pc" -exec perl -pi -e "s, -L$PWD/?\S+,,g" {} \;
	find $QT5PREFIX -name qt_lib_bootstrap_private.pri \
		   -exec sed -i -e "s:$PWD/qtbase:/$QT5PREFIX/lib/:g" {} \; &&
	find $QT5PREFIX -name \*.prl \
		   -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;

	install -v -dm755 /usr/share/pixmaps/                  &&
	install -v -Dm644 qttools/src/assistant/assistant/images/assistant-128.png \
	                  /usr/share/pixmaps/assistant-qt5.png &&
	install -v -Dm644 qttools/src/designer/src/designer/images/designer.png \
    	              /usr/share/pixmaps/designer-qt5.png  &&
	install -v -Dm644 qttools/src/linguist/linguist/images/icons/linguist-128-32.png \
    	              /usr/share/pixmaps/linguist-qt5.png  &&
	install -v -Dm644 qttools/src/qdbus/qdbusviewer/images/qdbusviewer-128.png \
    	              /usr/share/pixmaps/qdbusviewer-qt5.png &&
	install -dm755 /usr/share/applications &&

	cat > /usr/share/applications/assistant-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 Assistant 
Comment=Shows Qt5 documentation and examples
Exec=/opt/qt5/bin/assistant
Icon=assistant-qt5.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Documentation;
EOF

	cat > /usr/share/applications/designer-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 Designer
GenericName=Interface Designer
Comment=Design GUIs for Qt5 applications
Exec=/opt/qt5/bin/designer
Icon=designer-qt5.png
MimeType=application/x-designer;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

	cat > /usr/share/applications/linguist-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 Linguist
Comment=Add translations to Qt5 applications
Exec=/opt/qt5/bin/linguist
Icon=linguist-qt5.png
MimeType=text/vnd.trolltech.linguist;application/x-linguist;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

	cat > /usr/share/applications/qdbusviewer-qt5.desktop << EOF
[Desktop Entry]
Name=Qt5 QDbusViewer 
GenericName=D-Bus Debugger
Comment=Debug D-Bus applications
Exec=/opt/qt5/bin/qdbusviewer
Icon=qdbusviewer-qt5.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Debugger;
EOF

	for file in moc uic rcc qmake lconvert lrelease lupdate; do
		ln -sfrvn /opt/qt5/bin/$file /usr/bin/$file-qt5
	done
	
	cat >> /etc/ld.so.conf << EOF
# Begin Qt addition

/opt/qt5/lib

# End Qt addition
EOF

	ldconfig
	
	cat > /etc/profile.d/qt5.sh << EOF
# Begin /etc/profile.d/qt5.sh

QT5DIR=/opt/qt5

pathappend $QT5DIR/bin           PATH
pathappend $QT5DIR/lib/pkgconfig PKG_CONFIG_PATH

export QT5DIR

# End /etc/profile.d/qt5.sh
EOF
}

	cat > /usr/bin/setqt5 << 'EOF'
if [ "x$QT4DIR" != "x/usr" ]; then pathremove  $QT4DIR/bin; fi
if [ "x$QT5DIR" != "x/usr" ]; then pathprepend $QT5DIR/bin; fi
echo $PATH
EOF

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
