#!/bin/sh
set -o nounset	# exit if variable not initalized

# Configure Panda Setup
source "${PWD}/common/vars.sh"
source "${PWD}/common/functions.sh"

configureInstall() {
	# Remove /tools
	sudo rm -rf /tools
	# Remove old .config file
	rm -f "${PWD}/.config"
	# Create new .config
	cat > "${PWD}/.config" << "EOF"
#!/bin/sh
EOF

	echo -e "Download Packages?"
	select yn in "Yes" "No"; do
		case $yn in
			Yes ) 
				# Download All the packages
				wget --input-file=wget-list --continue --directory-prefix="$PWD/source"
				pushd "$PWD/source"
				md5sum -c ../md5sums
				popd;
				break;;
			No )
				break;;
		esac
	done

	echo "export MOUNT_POINT=${MOUNT_POINT}" >> "${PWD}/.config"

	echo -e "Filesystem: "
	read FILESYSTEM
	echo "export FILE_SYSTEM=${FILESYSTEM}" >> "${PWD}/.config"

	echo -e "Run in Debug Mode?"
	select yn in "Yes" "No"; do
		case $yn in
			Yes )
				echo -e "Turn on checks?"
				select yn in "Yes" "No"; do
					case $yn in
						Yes )	echo 'export MAKE_CHECK=TRUE' >> "${PWD}/.config";break;;
						No )	echo 'export MAKE_CHECK=FALSE' >> "${PWD}/.config";break;;
					esac
				done

				echo -e "Turn on parallelism?"
				select yn in "Yes" "No"; do
					case $yn in
						Yes )	echo 'export MAKE_PARALLEL="-j$(cat /proc/cpuinfo | grep processor | wc -l)"' >> "${PWD}/.config";break;;
						No ) 	echo 'export MAKE_PARALLEL=-j1' >> "${PWD}/.config";break;;
					esac
				done
				break ;;
			No )
				echo 'export MAKE_PARALLEL="-j$(cat /proc/cpuinfo | grep processor | wc -l)"' >> "${PWD}/.config";
				echo 'export MAKE_CHECK=FALSE' >> "${PWD}/.config";
				break ;;
		esac
	done

	echo "export TARGET=$TARGET" 		>> "${PWD}/.config"
	echo "export PATH=$TMP_PATH"		>> "${PWD}/.config"
	echo "export LC_ALL=$LC_ALL" 		>> "${PWD}/.config"
	echo "export VM_LINUZ=$VM_LINUZ" 		>> "${PWD}/.config"
	echo "export SYSTEM_MAP=$SYSTEM_MAP" 	>> "${PWD}/.config"
	echo "export CONFIG_BACKUP=$CONFIG_BACKUP">> "${PWD}/.config"

	# Make all the configurations available
	source "${PWD}/.config"
	# Mount the filesystem
	mountFs

	# Copy the data
	echo "Please wait..."
	echo " "
	cp -ur ./* "${MOUNT_POINT}"
	cp -ur "${PWD}"/.config "${MOUNT_POINT}"
	# Create /tools
	mkdir "${MOUNT_POINT}/tools"
	sudo ln -s "${MOUNT_POINT}/tools" /
	sudo chmod -Rv whoami /tools

	# Start the installation
	for i in {1..5}
	do
		cd "$MOUNT_POINT/phase${i}" && ./init.sh
	done

	# Unmount the filesystem
	umountFs
}

echo "Panda Linux Console Installer"
echo ""
echo "Note: Remain connected to the internet for the duration of the installation procedure."
configureInstall
