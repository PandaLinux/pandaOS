#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="cracklib"
PKG_VERSION="2.9.6"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
WORDS="${PKG_NAME}-words-${PKG_VERSION}.gz"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "/source/$TARBALL" "$TARBALL"
        ln -sv "/source/$WORDS" "$WORDS"
    fi
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {    
    sed -i '/skipping/d' util/packer.c &&

	./configure --prefix=/usr    \
    	        --disable-static \
    	        --with-default-dict=/lib/cracklib/pw_dict &&
	make $MAKE_PARALLEL    	        
}

function check() {
	make $MAKE_PARALLEL test
}

function instal() {
    make $MAKE_PARALLEL install			&&
	mv -v /usr/lib/libcrack.so.* /lib 	&&
	ln -sfv ../../../lib/$(readlink /usr/lib/libcrack.so) /usr/lib/libcrack.so
	
	install -v -m644 -D    ../${WORDS} \
	                         /usr/share/dict/cracklib-words.gz     		&&

	gunzip -v                /usr/share/dict/cracklib-words.gz     		&&
	ln -v -sf cracklib-words /usr/share/dict/words                 		&&
	echo "panda-linux" >>      /usr/share/dict/cracklib-extra-words  	&&
	install -v -m755 -d      /lib/cracklib                         		&&

	create-cracklib-dict     /usr/share/dict/cracklib-words \
    	                     /usr/share/dict/cracklib-extra-words
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;instal;[[ $MAKE_CHECK = TRUE ]] && check;popd;clean
