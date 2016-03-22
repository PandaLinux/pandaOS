#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

function clean() {
    strip --strip-debug /tools/lib/*
    /usr/bin/strip --strip-unneeded /tools/{,s}bin/*
    rm -rfv /tools/{,share}/{info,man,doc}
}

function prepare() {
    sudo chown -R root:root $MOUNT_POINT/tools
}

clean;prepare;
