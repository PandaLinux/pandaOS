#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

function clean() {
    strip --strip-debug /tools/lib/*
    /usr/bin/strip --strip-unneeded /tools/{,s}bin/*
    rm -rf /tools/{,share}/{info,man,doc}
}

function prepare() {
    sudo chown -R root:root $MOUNT_POINT/tools
}

clean;prepare;