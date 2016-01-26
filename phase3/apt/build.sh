#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="apt"
PKG_VERSION="1.2"

TARBALL="${PKG_NAME}_${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

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
	# this only copies config.{guess,sub}, dislpays some errors and creates a dummy config.rpath
	touch buildlib/config.rpath
	automake --add-missing --no-force -W none
	
	./configure --prefix=/usr 			\
				--sysconfdir=/etc 		\
				--localstatedir=/var 	\
				--sbindir=/usr/bin		&&
	make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
	# Create all the required directories
	mkdir -pv /usr/{include/{apt-pkg,apt-private},share/doc/apt/examples,lib/{dpkg/methods/apt,apt/{solvers,methods}}}
	mkdir -pv /etc/apt/{apt.conf.d,sources.list.d,preferences.d}

	# apt
	for file in {cache,cdrom,config,get,key,mark}; do
		install bin/apt-$file /usr/bin/
	done
	install bin/apt /usr/bin
	
	# apt-utils
	for file in {extracttemplates,sortpkgs}; do
		install bin/apt-$file /usr/bin/
	done
	
	# libapt-inst
	install bin/libapt-inst.so.2.0 /usr/lib
	ln -srv bin/libapt-inst.so.2.0 /usr/lib/libapt-inst.so.2.0.0
	ln -srv bin/libapt-inst.so.2.0 /usr/lib/libapt-inst.so
	
	# libapt-pkg
	install bin/libapt-pkg.so.5.0 /usr/lib
	ln -srv bin/libapt-pkg.so.5.0 /usr/lib/libapt-pkg.so.5.0.0
	ln -srv bin/libapt-pkg.so.5.0 /usr/lib/libapt-pkg.so
	
	# libapt-private
	install bin/libapt-private.so.0.0 /usr/lib
	ln -srv bin/libapt-private.so.0.0 /usr/lib/libapt-private.so.0.0.0
	ln -srv bin/libapt-private.so.0.0 /usr/lib/libapt-private.so
	
	# apt solvers
	install bin/apt-internal-solver /usr/lib/apt/solvers/apt
	install bin/apt-dump-solver /usr/lib/apt/solvers/dump
	
	# apt methods
	install bin/methods/* /usr/lib/apt/methods
	install dselect/{install,setup,update} /usr/lib/dpkg/methods/apt
	install -m 644 dselect/{desc.apt,names} /usr/lib/dpkg/methods/apt	
	
	# All example configs
	install -m 644 doc/examples/* /usr/share/doc/apt/examples
	
	# All locales
	for lang in locale/*; do
		mkdir -pv /usr/share/$lang/LC_MESSAGES
		install -m 644 $lang/LC_MESSAGES/* /usr/share/$lang/LC_MESSAGES
	done
	
	# libapt-pkg-dev
	install -m 644 include/apt-pkg/* /usr/include/apt-pkg
	
	# libapt-private-dev
	install -m 644 include/apt-private/* /usr/include/apt-private
	
    cat > /etc/apt/sources.list << "EOF"
## Begin /etc/apt/sources.list

deb http://panda-linux.esy.es/ftp/panda black main
deb-src http://panda-linux.esy.es/ftp/panda black main

## End /etc/apt/sources.list
EOF
	
	# Add the sandbox user '_apt'
	sudo useradd -r -M --system _apt

	sudo wget -q http://panda-linux.esy.es/ftp/panda/panda.gpg.key -O- | sudo apt-key add -
	sudo apt update
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
