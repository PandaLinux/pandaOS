#!/bin/sh

shopt -s -o pipefail
set -e 		# Exit on error

function clean() {
    /tools/bin/find /{,usr/}{bin,lib,sbin} -type f \
		    -exec /tools/bin/strip --strip-debug '{}' ';'

    rm -rfv /tmp/*
    rm -v /usr/lib/lib{bfd,opcodes}.a
    rm -v /usr/lib/libbz2.a
    rm -v /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
    rm -v /usr/lib/libltdl.a
    rm -v /usr/lib/libz.a
}

clean;
