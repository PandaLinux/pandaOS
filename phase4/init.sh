#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

source "$MOUNT_POINT/common/functions.sh"

_list=()

for i in ${_list[@]}; do
    case $i in

	* ) 
            pushd ${i} || (echo "${i} --> Not found in list error -->$?";exit 1)
                if [ -e DONE ]; then
                    echo "${i} --> Already Built"
                else
                    echo "Building---> ${i}"
                    enterChroot "source config && source /phase4/tmpExports && cd /phase4/$i && (bash build.sh |& tee build.log ) || false"
                    echo "Build ---> ${i} completed"
                    touch DONE
                fi
            popd;;
    esac
done