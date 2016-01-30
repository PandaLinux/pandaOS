#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

source "$MOUNT_POINT/common/functions.sh"

_list=(kf5-setup dbus libevent sqlite pcre grep glib shared-mime-info desktop-file-utils ruby qt libdbusmenu-qt phonon vlc phonon-backend-vlc nspr zip js polkit polkit-qt libgudev modem-manager dbus-glib libnl nss libndp network-manager libical bluez uri sgml-common docbook-xml docbook-xsl libxslt boost giflib yasm libjpeg-turbo lmdb kf5-frameworks kf5-plasma) # sddm)
 
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
