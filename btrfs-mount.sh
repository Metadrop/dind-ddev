#!/bin/bash

set -ex

BTRFS_FILE=${1:-$BTRFS_FILE_DEFAULT}
DATA_ROOT=${2:-$DATA_ROOT_DEFAULT}
BTRFS_SIZE=${3:-$BTRFS_SIZE_DEFAULT}

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
mkdir -p $DATA_ROOT
chmod 410 $DATA_ROOT
mount $DEVICE $DATA_ROOT
