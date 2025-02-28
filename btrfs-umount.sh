#!/bin/bash

set -ex

BTRFS_FILE=${1:-$BTRFS_FILE_DEFAULT}
DATA_ROOT=${2:-$DATA_ROOT_DEFAULT}

sync
umount $DATA_ROOT

DEVICE=$(losetup --list --noheadings --associated $BTRFS_FILE | awk '{print $1}')
if [ -n $DEVICE ]; then
  losetup --detach $DEVICE
fi
