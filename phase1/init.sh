#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

_list=(binutils-pass-1 gcc-pass-1 linux-api-headers glibc libstdcxx binutils-pass-2 gcc-pass-2 tcl expect dejagnu check ncurses bash bzip2 coreutils diffutils file findutils gawk gettext grep gzip m4 make patch perl sed tar texinfo util-linux xz clean)

for i in ${_list[@]}; do
    case $i in
        tcl ) 
            if [ $MAKE_CHECK = TRUE ]
            then
                pushd tcl
                    if [ -e DONE ]; then
                        echo "tcl --> Already Built"
                    else
                        echo "Building---> tcl"
                        ( ./build.sh |& tee build.log ) || false
                        echo "Build ---> tcl completed"
                        touch DONE
                    fi
                popd
            fi ;;
            
        expect ) 
            if [ $MAKE_CHECK = TRUE ]
            then
                pushd expect
                    if [ -e DONE ]; then
                        echo "expect --> Already Built"
                    else
                        echo "Building---> expect"
                        ( ./build.sh |& tee build.log ) || false
                        echo "Build ---> expect completed"
                        touch DONE
                    fi
                popd
            fi ;;
            
        dejagnu ) 
            if [ $MAKE_CHECK = TRUE ]
            then
                pushd dejagnu
                    if [ -e DONE ]; then
                        echo "dejagnu --> Already Built"
                    else
                        echo "Building---> dejagnu"
                        ( ./build.sh |& tee build.log ) || false
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
                    ( ./build.sh |& tee build.log ) || false
                    echo "Build ---> ${i} completed"
                    touch DONE
                fi
            popd;;
    esac
done
