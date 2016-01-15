#!/bin/sh

# Update the system
sudo apt-get update && sudo apt-get upgrade --yes --force-yes

# Install GCC 5
sudo apt-get install --yes --force-yes bash binutils bison bzip2 coreutils diffutils findutils gawk grep gzip m4 make patch perl sed tar texinfo xz-utils
sudo add-apt-repository ppa:ubuntu-toolchain-r/test --yes
sudo apt-get update
sudo apt-get install --yes --force-yes gcc-5 g++-5
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 80 --slave /usr/bin/g++ g++ /usr/bin/g++-5
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8

# Setup bash as default shell
sudo rm -f /bin/sh
sudo ln -s /bin/bash /bin/sh