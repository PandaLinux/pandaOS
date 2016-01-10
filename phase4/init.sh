#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

source "$MOUNT_POINT/common/functions.sh"

_list=(nettle libtasn1 gnutls wget xorg-init util-macros xorg-protocol-headers libXau libXdmcp python2 libxml2 xcb-proto check libxcb freetype harfbuzz freetype fontconfig xorg-libraries xcb-util xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm libpciaccess libdrm elfutils libva libvdpau libffi llvm wayland mesa libva libvdpau xbitmaps libpng xorg-applications xcursor-themes xorg-fonts libxslt xkeyboard-config pixman libepoxy cracklib linux-pam shadow zip nspr js pcre glib polkit systemd xorg-server libevdev mtdev xorg-evdev-driver xorg-synaptics-driver xorg-ati-driver xorg-fbdev-driver xorg-intel-driver xorg-nouveau-driver xorg-vesa-driver linux-kernel twm xterm xclock xinit)

for i in ${_list[@]}; do
    case $i in

	* ) 
            pushd ${i} || (echo "${i} --> Not found in list error -->$?";exit 1)
                if [ -e DONE ]; then
                    echo "${i} --> Already Built"
                else
                    echo "Building---> ${i}"
                    enterChroot "source config && source tmpExports && cd /phase4/$i && (bash build.sh |& tee build.log ) || false"
                    echo "Build ---> ${i} completed"
                    touch DONE
                fi
            popd;;
    esac
done