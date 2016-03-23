#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

_list=(binutils-pass-1 gcc-pass-1 linux-api-headers glibc libstdcxx binutils-pass-2 gcc-pass-2 tcl expect dejagnu check ncurses bash bzip2 coreutils diffutils file findutils gawk gettext grep gzip m4 make patch perl sed tar texinfo util-linux xz clean)

for i in ${_list[@]}; do
    case $i in
        * ) 
            pushd ${i} || (echo "${i} --> Not found in list error -->$?";exit 1)
                if [ -e DONE ]; then
                    echo "${i} --> Already Built"
                else
                    echo "Building ---> ${i}"
                    ( ./build.sh |& tee build.log ) || false
                    echo "Build ---> ${i} completed"
                    touch DONE
                fi
            popd;;
    esac
done
