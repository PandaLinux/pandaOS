#!/bin/sh

set +h  # disable hashall
shopt -s -o pipefail

strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
rm -rf /tools/{,share}/{info,man,doc}

chown -R root:root $FAKEROOT/tools