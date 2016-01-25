#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

source "$MOUNT_POINT/common/functions.sh"

_list=(bash network clock inputrc shell fstab linux-kernel grub lsb lsb-release linux-pam shadow sudo dpkg unzip openssl wget cert curl libgpg-error libksba libgcrypt libassuan pth pin-entry npth gnupg which libarchive cmake gtest apt nano)

for i in ${_list[@]}; do
    case $i in

	* ) 
            pushd ${i} || (echo "${i} --> Not found in list error -->$?";exit 1)
                if [ -e DONE ]; then
                    echo "${i} --> Already Built"
                else
                    echo "Building---> ${i}"
                    enterChroot "source /.config && cd /phase3/$i && (bash build.sh |& tee build.log ) || false"
                    echo "Build ---> ${i} completed"
                    touch DONE
                fi
            popd;;
    esac
done
