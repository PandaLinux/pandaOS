#!/bin/sh

# Safely mount the filesystems
function mountFs() {
    echo " "
    sudo mkdir -v "$MOUNT_POINT"
    sudo mount -t ext4 "$FILESYSTEM" "$MOUNT_POINT" && echo "$FILESYSTEM is now mounted" || echo "Unable to mount $FILESYSTEM"
    sudo chown -v $(whoami) "${MOUNT_POINT}"
    echo " "
    echo "ALL DONE!"
    echo " "
}

# Safely unmount the filesystems
function umountFs() {
    echo " "
    sudo umount -l "$FILESYSTEM" && echo "$FILESYSTEM is now unmounted" || echo "Unable to unmount $FILESYSTEM"
    echo " "
    echo "ALL DONE!"
    echo " "
}

# Enter chroot environment
function enterChrootTmp() {
    # Mounting and Populating /dev
    sudo mount --bind /dev "$MOUNT_POINT/dev"
    
    # Mount Virtual Kernel File Systems
    sudo mount -t devpts devpts "$MOUNT_POINT/dev/pts"
    sudo mount -t proc proc "$MOUNT_POINT/proc"
    sudo mount -t sysfs sysfs "$MOUNT_POINT/sys"
    sudo mount -t tmpfs tmpfs "$MOUNT_POINT/run"
    
    sudo chroot "$MOUNT_POINT" /tools/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='\u:\w\$ '              \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash -c "$@"
    
    sync
    sleep 1        
    
    sudo umount -l "$MOUNT_POINT/run"
    sudo umount -l "$MOUNT_POINT/sys"
    sudo umount -l "$MOUNT_POINT/proc"
    sudo umount -l "$MOUNT_POINT/dev/pts"
    
    sudo umount -l "$MOUNT_POINT/dev"
}

# Enter chroot environment
function enterChroot() {
    # Mounting and Populating /dev
    sudo mount --bind /dev "$MOUNT_POINT/dev"
    
    # Mount Virtual Kernel File Systems
    sudo mount -t devpts devpts "$MOUNT_POINT/dev/pts"
    sudo mount -t proc proc "$MOUNT_POINT/proc"
    sudo mount -t sysfs sysfs "$MOUNT_POINT/sys"
    sudo mount -t tmpfs tmpfs "$MOUNT_POINT/run"
    
    sudo chroot "$MOUNT_POINT" /usr/bin/env -i 	\
    HOME=/root TERM="$TERM" PS1='\u:\w\$ ' 	\
    PATH=/bin:/usr/bin:/sbin:/usr/sbin     	\
    /bin/bash -c "$@"
    
    sync
    sleep 1  
    
    sudo umount -l "$MOUNT_POINT/run"
    sudo umount -l "$MOUNT_POINT/sys"
    sudo umount -l "$MOUNT_POINT/proc"
    sudo umount -l "$MOUNT_POINT/dev/pts"
    
    sudo umount -l "$MOUNT_POINT/dev"
}
