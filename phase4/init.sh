#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

source "$MOUNT_POINT/common/functions.sh"

_list=(x-setup util-macros xorg-protocol-headers libXau libXdmcp tcl expect dejagnu libffi python2 python3 check libxml2 xcb-proto libxcb freetype harfbuzz freetype font-config xorg-libraries xcb-util xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm libpciaccess libdrm wayland llvm elfutils mesa xbitmaps libpng xorg-applications xcursor-themes xorg-fonts xkeyboard-config libpciaccess pixman libepoxy systemd xorg-server libevdev xorg-evdev-driver xorg-ati-driver xorg-intel-driver twm xterm xclock xinit)

for i in ${_list[@]}; do
    case $i in        		

	* ) 
            pushd ${i} || (echo "${i} --> Not found in list error -->$?";exit 1)
                if [ -e DONE ]; then
                    echo "${i} --> Already Built"
                else
                    echo "Building---> ${i}"
                    enterChroot "source config && source /phase4/exports && cd /phase4/$i && (bash build.sh |& tee build.log ) || false"
                    echo "Build ---> ${i} completed"
                    touch DONE
                fi
            popd;;
    esac
done
