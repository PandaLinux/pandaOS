#!/bin/sh
set -o nounset	# exit if variable not initalized

# Configure Panda Setup
source "${PWD}/common/vars.sh"
source "${PWD}/common/functions.sh"

configureInstall() {
    # Remove /tools
    sudo rm -rf /tools
    # Remove old .config file
    rm -f "${PWD}/config"
    # Create new .config
    cat > "${PWD}/config" << "EOF"
#!/bin/sh
EOF

     echo -e "Moint Point: "
     read MOUNT_POINT
     echo "export MOUNT_POINT=${MOUNT_POINT}" >> "${PWD}/config"
    
     echo -e "Filesystem: "
     read FILESYSTEM
     echo "export FILE_SYSTEM=${FILESYSTEM}" >> "${PWD}/config"

#     echo -e "Turn on debug mode (Not yet supported)?"
#     select yn in "Yes" "No"; do
#         case $yn in
#             Yes ) echo 'export DEBUG=TRUE' >> "${PWD}/config";break;;
#             No ) echo 'export DEBUG=FALSE' >> "${PWD}/config";break;;
#         esac
#     done
    
    echo -e "Turn on checks?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) echo 'export MAKE_CHECK=TRUE' >> "${PWD}/config";break;;
            No ) echo 'export MAKE_CHECK=FALSE' >> "${PWD}/config";break;;
        esac
    done
    
#     echo -e "Turn on colors (Not yet supported)?"
#     select yn in "Yes" "No"; do
#         case $yn in
#             Yes ) echo 'export SHOW_COLORS=TRUE' >> "${PWD}/config";break;;
#             No ) echo 'export SHOW_COLORS=FALSE' >> "${PWD}/config";break;;
#         esac
#     done
    
    echo -e "Turn on parallelism?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) echo 'export MAKE_PARALLEL="-j$(cat /proc/cpuinfo | grep processor | wc -l)"' >> "${PWD}/config";break;;
            No ) echo 'export MAKE_PARALLEL=-j1' >> "${PWD}/config";break;;
        esac
    done
    
    echo 'export TARGET="$(uname -m)-panda-linux-gnu"' >> "${PWD}/config"
    echo 'export PATH=/tools/bin:/bin:/usr/bin' >> "${PWD}/config"
    echo 'export LC_ALL=POSIX' >> "${PWD}/config"
    echo 'export VM_LINUZ=vmlinuz-4.2-systemd' >> "${PWD}/config"
    echo 'export SYSTEM_MAP=System.map-4.2' >> "${PWD}/config"
    echo 'export CONFIG_BACKUP=config-4.2' >> "${PWD}/config"
    
    # Make all the configurations available
    source "${PWD}/config"
    # Mount the filesystem
    mountFs
    
    # Download All the packages
#    wget --input-file=wget-list-phase1 --continue --directory-prefix="$PWD/source"
#    wget --input-file=wget-list-phase3 --continue --directory-prefix="$PWD/source"
    pushd "$PWD/source"
    md5sum -c md5sums-phase1
    md5sum -c md5sums-phase3
    popd
    
    # Copy the data
    cp -ur ./* "${MOUNT_POINT}"
    # Create /tools
    mkdir "${MOUNT_POINT}/tools"
    sudo ln -s "${MOUNT_POINT}/tools" /

    # Start Installations
    cd "${MOUNT_POINT}/phase1"
    bash init.sh
    cd "${MOUNT_POINT}/phase2"
    bash init.sh
    cd "${MOUNT_POINT}/phase3"
    bash init.sh
    cd "${MOUNT_POINT}/phase4"
    bash init.sh

   # Unmount the filesystem
   umountFs
   
   echo -e "Update Grub?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) updateGrub;break;;
            No ) break;;
        esac
    done
}

echo "Panda Linux Console Installer"
echo ""
echo "Note: Remain connected to the internet for the duration of the installation procedure."
configureInstall
