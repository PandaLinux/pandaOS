#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

source "$MOUNT_POINT/common/functions.sh"
echo 'export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin' >> "$MOUNT_POINT/config"

_list=(structure linux-api-headers man-pages glibc adjust-toolchain zlib file binutils gmp mpfr mpc gcc bzip2 pkg-config ncurses attr acl libcap sed shadow psmisc procps-ng e2fsprogs coreutils iana-etc m4 flex bison grep readline bash bc libtool gdbm expat inetutils perl xml-parser autoconf automake diffutils gawk findutils gettext intltool gperf groff xz grub less gzip iproute2 kbd kmod libpipeline make patch systemd dbus util-linux man-db tar texinfo vim clean)

for i in ${_list[@]}; do
    case $i in

	* ) 
            pushd ${i} || (echo "${i} --> Not found in list error -->$?";exit 1)
                if [ -e DONE ]; then
                    echo "${i} --> Already Built"
                else
                    echo "Building---> ${i}"
                    enterChrootTmp "source config && cd /phase2/$i && (bash build.sh |& tee build.log ) || false"
                    echo "Build ---> ${i} completed"
                    touch DONE
                fi
            popd;;
    esac
done