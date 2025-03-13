#!/bin/bash

set -ex

/usr/local/bin/btrfs-mount.sh
dockerd > /var/log/dockerd.log 2>&1 &
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

# Truncate filesystem.
SIZE_MAJOR=$(btrfs filesystem usage -g $DATA_ROOT_DEFAULT | grep "Device allocated" | sed 's/.*:[[:space:]]*\([[:digit:]]\+\)\..*GiB/\1/g')
NEW_SIZE="$(( $SIZE_MAJOR + 1 ))G"
btrfs filesystem resize $NEW_SIZE $DATA_ROOT_DEFAULT
/usr/local/bin/btrfs-umount.sh
truncate -s $NEW_SIZE $BTRFS_FILE_DEFAULT
