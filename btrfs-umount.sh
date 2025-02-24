#!/bin/sh

set -x

sync
umount /var/lib/docker

DEVICE=$(losetup --list --noheadings --associated $BTRFS_FILE | awk '{print $1}')
if [ -n $DEVICE ]; then
  losetup --detach $DEVICE
fi
