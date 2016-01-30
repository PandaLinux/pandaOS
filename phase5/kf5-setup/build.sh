#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

function prepare() {
    cat > /etc/profile.d/kf5.sh << "EOF"
# Begin /etc/profile.d/kf5.sh

. /etc/profile.d/qt5.sh

export KF5_PREFIX=/opt/kf5

pathappend $KF5_PREFIX                             CMAKE_PREFIX_PATH
pathappend $KF5_PREFIX/bin                         PATH
pathappend $KF5_PREFIX/lib/pkgconfig               PKG_CONFIG_PATH
pathappend $KF5_PREFIX/lib/python2.7/site-packages PYTHONPATH

pathappend /etc/xdg                  XDG_CONFIG_DIRS
pathappend $KF5_PREFIX/etc/xdg       XDG_CONFIG_DIRS
pathappend /usr/share                XDG_DATA_DIRS
pathappend $KF5_PREFIX/share         XDG_DATA_DIRS

pathappend /usr/lib/qt5/plugins        QT_PLUGIN_PATH
pathappend $QT5DIR/lib/qt5/plugins     QT_PLUGIN_PATH
pathappend $KF5_PREFIX/lib/qt5/plugins QT_PLUGIN_PATH

pathappend /usr/lib/qt5/qml            QML_IMPORT_PATH
pathappend $QT5DIR/lib/qt5/qml         QML_IMPORT_PATH
pathappend $KF5_PREFIX/lib/qt5/qml     QML_IMPORT_PATH

pathappend /usr/lib/qt5/qml            QML2_IMPORT_PATH
pathappend $QT5DIR/lib/qt5/qml         QML2_IMPORT_PATH
pathappend $KF5_PREFIX/lib/qt5/qml     QML2_IMPORT_PATH

# End /etc/profile.d/kf5.sh
EOF

	cat >> /etc/ld.so.conf << "EOF"
# Begin KF5 addition

/opt/kf5/lib

# End KF5 addition
EOF

	install -v -dm755 $KF5_PREFIX/{etc,share}     &&
	ln -sfv /etc/dbus-1         $KF5_PREFIX/etc   &&
	ln -sfv /usr/share/dbus-1   $KF5_PREFIX/share
	
	install -v -dm755 $KF5_PREFIX/share/icons &&
	ln -sfv /usr/share/icons/hicolor $KF5_PREFIX/share/icons
}

prepare;
