#!/bin/sh

set +h		# disable hashall
set -e 		# exit if tool chain is incorrect
shopt -s -o pipefail

function prepare() {
    mv -v /tools/bin/{ld,ld-old}
	mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
	mv -v /tools/bin/{ld-new,ld}
	ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld
}

function build() {
    gcc -dumpspecs | sed -e 's@/tools@@g'                   \
		-e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
		-e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
		`dirname $(gcc --print-libgcc-file-name)`/specs
}

function check() {
    echo 'int main(){}' > build.c
	cc build.c -v -Wl,--verbose &> build.log
	readelf -l a.out | grep ': /lib'
	
	grep -o '/usr/lib.*/crt[1in].*succeeded' build.log
	grep -B1 '^ /usr/include' build.log
	grep 'SEARCH.*/usr/lib' build.log |sed 's|; |\n|g'
	grep "/lib.*/libc.so.6 " build.log
	grep found build.log
}

function instal() {
    echo " "
}

function clean() {
    rm -v build.c a.out
}

prepare;build;check;instal;clean;
