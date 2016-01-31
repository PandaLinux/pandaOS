#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

source "$MOUNT_POINT/common/functions.sh"

_list=(util-macros xorg-protocol-headers libXau libXdmcp tcl expect dejagnu libffi python2 python3 check libxml2 xcb-proto libxcb glib icu freetype harfbuzz freetype font-config xorg-libraries xcb-util xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xcb-util-cursor libpciaccess libdrm wayland llvm elfutils mesa xbitmaps libpng xorg-applications xcursor-themes xorg-fonts xkeyboard-config libpciaccess pixman libepoxy systemd xorg-server libevdev xorg-evdev-driver linux-kernel xorg-intel-driver xinit)

for i in ${_list[@]}; do
    case $i in
    
	tcl ) 
		if [ $MAKE_CHECK = TRUE ]
		then
			pushd tcl || (echo "tcl --> Not found in list error -->$?";exit 1)
				if [ -e DONE ]; then
					echo "tcl --> Already Built"
				else
			        echo "Building---> tcl"
					enterChroot "source /.config && source /phase4/exports && cd /phase4/tcl && (bash build.sh |& tee build.log ) || false"
					echo "Build ---> tcl completed"
					touch DONE
				fi
			popd
		fi ;;
            
	expect ) 
		if [ $MAKE_CHECK = TRUE ]
		then
			pushd expect || (echo "expect --> Not found in list error -->$?";exit 1)
				if [ -e DONE ]; then
					echo "expect --> Already Built"
				else
					echo "Building---> expect"
					enterChroot "source /.config && source /phase4/exports && cd /phase4/expect && (bash build.sh |& tee build.log ) || false"
				    echo "Build ---> expect completed"
					touch DONE
				fi
			popd
		fi ;;
            
	dejagnu ) 
		if [ $MAKE_CHECK = TRUE ]
		then
			pushd dejagnu || (echo "tcl --> Not found in list error -->$?";exit 1)
				if [ -e DONE ]; then
					echo "dejagnu --> Already Built"
				else
					echo "Building---> dejagnu"
					enterChroot "source /.config && source /phase4/exports && cd /phase4/dejagnu && (bash build.sh |& tee build.log ) || false"
					echo "Build ---> dejagnu completed"
					touch DONE
				fi
			popd
		fi ;;

	* ) 
		pushd ${i} || (echo "${i} --> Not found in list error -->$?";exit 1)
			if [ -e DONE ]; then
				echo "${i} --> Already Built"
			else
		        echo "Building---> ${i}"
				enterChroot "source /.config && source /phase4/exports && cd /phase4/$i && (bash build.sh |& tee build.log ) || false"
				echo "Build ---> ${i} completed"
				touch DONE
			fi
		popd;;
	esac
done
