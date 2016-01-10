#!/bin/sh

shopt -s -o pipefail

function clean() {
    /tools/bin/find /{,usr/}{bin,lib,sbin} -type f \
		    -exec /tools/bin/strip --strip-debug '{}' ';'

    rm -rf /tmp/*
    rm /usr/lib/lib{bfd,opcodes}.a
    rm /usr/lib/libbz2.a
    rm /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
    rm /usr/lib/libltdl.a
    rm /usr/lib/libz.a
}

clean;