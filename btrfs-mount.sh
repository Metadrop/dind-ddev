#!/bin/sh

set -x

# Initialize volume file.
if [ ! -f $BTRFS_FILE ]; then
  dd if=/dev/null bs=1 seek=$BTRFS_SIZE of=$BTRFS_FILE
fi

# Link volume file to loop device.
DEVICE=$(losetup --show --find --partscan $BTRFS_FILE)

# Format the device if not already formatted.
if [ ! "$(blkid -o value -s TYPE $DEVICE)" ]; then
  mkfs.btrfs $DEVICE
fi

# Mount device to dockerd data root.
mkdir -p /var/lib/docker
chmod 410 /var/lib/docker
mount -o discard $DEVICE /var/lib/docker
