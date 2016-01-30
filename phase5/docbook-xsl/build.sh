#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="docbook-xsl"
PKG_VERSION="1.79.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "/source/$TARBALL" "$TARBALL"
    fi
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	echo " "
}

function check() {
	echo " "
}

function instal() {
	install -v -m755 -d /usr/share/xml/docbook/xsl-stylesheets-1.79.1 &&

	cp -v -R VERSION assembly common eclipse epub epub3 extensions fo        \
    	     highlighting html htmlhelp images javahelp lib manpages params  \
    	     profiling roundtrip slides template tests tools webhelp website \
    	     xhtml xhtml-1_1 xhtml5                                          \
    		/usr/share/xml/docbook/xsl-stylesheets-1.79.1 &&

	ln -s VERSION /usr/share/xml/docbook/xsl-stylesheets-1.79.1/VERSION.xsl &&

	install -v -m644 -D README \
    	                /usr/share/doc/docbook-xsl-1.79.1/README.txt &&
	install -v -m644    RELEASE-NOTES* NEWS* \
    	                /usr/share/doc/docbook-xsl-1.79.1
    	                
	if [ ! -d /etc/xml ]; then install -v -m755 -d /etc/xml; fi &&
	if [ ! -f /etc/xml/catalog ]; then
    	xmlcatalog --noout --create /etc/xml/catalog
	fi &&

	xmlcatalog --noout --add "rewriteSystem"										\
    					     "http://docbook.sourceforge.net/release/xsl/1.79.1" 	\
							 "/usr/share/xml/docbook/xsl-stylesheets-1.79.1" 		\
    /etc/xml/catalog &&
	xmlcatalog --noout --add "rewriteURI"											\
							 "http://docbook.sourceforge.net/release/xsl/1.79.1" 	\
							 "/usr/share/xml/docbook/xsl-stylesheets-1.79.1" 		\
    /etc/xml/catalog &&
	xmlcatalog --noout --add "rewriteSystem" 										\
							 "http://docbook.sourceforge.net/release/xsl/current" 	\
							 "/usr/share/xml/docbook/xsl-stylesheets-1.79.1"		\
    /etc/xml/catalog &&
	xmlcatalog --noout --add "rewriteURI" 											\
							 "http://docbook.sourceforge.net/release/xsl/current" 	\
							 "/usr/share/xml/docbook/xsl-stylesheets-1.79.1" 		\
    /etc/xml/catalog
    
    xmlcatalog --noout --add "rewriteSystem" 										\
							 "http://docbook.sourceforge.net/release/xsl/<version>" \
							 "/usr/share/xml/docbook/xsl-stylesheets-<version>" 	\
    /etc/xml/catalog &&
	xmlcatalog --noout --add "rewriteURI" 											\
							 "http://docbook.sourceforge.net/release/xsl/<version>" \
							 "/usr/share/xml/docbook/xsl-stylesheets-<version>" 	\
    /etc/xml/catalog
}

function clean() {
    rm -rf "${SRC_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
