#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # 
# GLOBAL VARIABLES TO BE USED BY THE INSTALLER
# 
# DO NOT EDIT THIS FILE
# # # # # # # # # # # # # # # # # # # # # # # # # # 

## Filesystem to be provided by the user
FILESYSTEM=""
## This is where the filesystem is mounted
MOUNT_POINT="/mnt/panda-linux"

## Rest of the configurations
TARGET="$(uname -m)-panda-linux-gnu"
TMP_PATH="/tools/bin:/bin:/usr/bin"
LC_ALL="POSIX"
VM_LINUZ="vmlinuz-4.4.2-systemd"
SYSTEM_MAP="System.map-4.4.2"
CONFIG_BACKUP="config-4.4.2"

