#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

source "$MOUNT_POINT/common/functions.sh"

_list=(kf5-setup dbus libevent sqlite shared-mime-info desktop-file-utils ruby gstreamer gst-plugins-base) # mtdev yasm libjpeg-turbo libtiff libsndfile json-c pulse-audio qt libdbusmenu-qt phonon vlc phonon-backend-vlc nspr zip js polkit polkit-qt libgudev modem-manager dbus-glib libnl nss libndp network-manager libical bluez uri sgml-common docbook-xml docbook-xsl boost giflib lmdb kf5-frameworks cairo pango gdk-pixbuf atk hicolor-icon-theme gtk+2 font-forge at-spi2-core atk at-spi2-atk gtk+3 libpwquality libxkbcommon taglib libinput qca kf5-plasma) # sddm)
 
for i in ${_list[@]}; do
    case $i in    

	* ) 
		pushd ${i} || (echo "${i} --> Not found in list error -->$?";exit 1)
			if [ -e DONE ]; then
				echo "${i} --> Already Built"
			else
		        echo "Building---> ${i}"
				enterChroot "source /.config && source /phase5/exports && cd /phase5/$i && (bash build.sh |& tee build.log ) || false"
				echo "Build ---> ${i} completed"
				touch DONE
			fi
		popd;;
	esac
done
