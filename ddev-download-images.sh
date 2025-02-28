#!/bin/bash

set -ex

# Initialize tmp volume file.
BTRFS_FILE_TMP="${BTRFS_FILE_DEFAULT}_tmp"
DATA_ROOT_TMP="${DATA_ROOT_DEFAULT}_tmp"
btrfs-mount.sh $BTRFS_FILE_TMP $DATA_ROOT_TMP

# Init docker.
dockerd --data-root $DATA_ROOT_TMP > /var/log/dockerd.log 2>&1 &
sleep 2

# Download images.
sudo -u ddev /usr/bin/ddev debug download-images

# TODO Remove ddev.

# dockerd cleanup (remove the .pid file as otherwise it prevents
# dockerd from launching correctly inside sys container)
kill $(cat /var/run/docker.pid)
kill $(cat /run/docker/containerd/containerd.pid)
rm -f /var/run/docker.pid
rm -f /run/docker/containerd/containerd.pid
sleep 2

# Create definitive file with adjusted size and copy dat over.
# Notes:
#  - 100MB. The minimum size for each btrfs device.
#  - We want to round up for 512-byte sectors.
SIZE_CURRENT=$(du -s --block-size=1 $DATA_ROOT_TMP | cut -f 1)

# Pick adequate size.
BTRFS_MIN_SIZE=114294784
SIZE_NEW=$(( $SIZE_CURRENT > $BTRFS_MIN_SIZE ? $SIZE_CURRENT : $BTRFS_MIN_SIZE ))
## Theoretically we should pick the max of SIZE_CURRENT and BTRFS_MIN_SIZE
## But in practice it doesn't play nice and the fs needs some extra room,
## so we dediced to sum both values, so we have an extra room of 100MB over
## the minimum required size.

# Round new size for 512-byte sectors.
BYTE_SECTOR=512
SIZE_NEW=$(( (($SIZE_NEW + ($BYTE_SECTOR/2)) / $BYTE_SECTOR) * $BYTE_SECTOR )) # Round up to the closest multiple of $BYTE_SECTOR

# Mount new volume, copy over and clean up.
btrfs-mount.sh $BTRFS_FILE_DEFAULT $DATA_ROOT_DEFAULT $SIZE_NEW
rsync -aP --quiet $DATA_ROOT_TMP/ $DATA_ROOT_DEFAULT/
btrfs-umount.sh
btrfs-umount.sh $BTRFS_FILE_TMP $DATA_ROOT_TMP
rm -rf $BTRFS_FILE_TMP $DATA_ROOT_TMP
