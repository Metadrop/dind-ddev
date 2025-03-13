#!/bin/bash

echo "Resizing images volume to ${BTRFS_SIZE_DEFAULT}..."
truncate -s $BTRFS_SIZE_DEFAULT $BTRFS_FILE_DEFAULT
/usr/local/bin/btrfs-mount.sh
btrfs filesystem resize max $DATA_ROOT_DEFAULT

dockerd --tls=false --host=tcp://0.0.0.0:2375 --host=unix:///var/run/docker.sock
