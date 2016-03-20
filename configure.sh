#!/bin/sh

function configure() {
    # Update the system
    sudo apt-get update && sudo apt-get upgrade --yes --force-yes

    # Install all the required dependencies
    sudo apt-get install --yes --force-yes bash binutils bison bzip2 coreutils diffutils findutils gawk grep gzip m4 make patch perl sed tar texinfo unzip xz-utils

    # Install GCC 5
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test --yes
    sudo apt-get update
    sudo apt-get install --yes --force-yes gcc-5 g++-5
    sudo apt-get remove --yes --force-yes gcc-4* g++-4*

    # Setup bash as default shell
    sudo rm -f /bin/sh
    sudo ln -s /bin/bash /bin/sh
}

rm -f configure.log && configure | tee configure.log
