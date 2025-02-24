#!/bin/sh

set -x

mkdir -p /var/lib/docker
chmod 410 /var/lib/docker

# Link btrs file to loop device.
DEVICE=$(losetup --show --find --partscan $BTRFS_FILE)

# TODO Format the device if not already formatted.
if [ ! "$(blkid -o value -s TYPE $DEVICE)" ]; then
  mkfs.btrfs $DEVICE
fi

# Mount device.
mount $DEVICE /var/lib/docker
