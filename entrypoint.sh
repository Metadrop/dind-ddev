#!/bin/bash

truncate -s $BTRFS_SIZE_DEFAULT $BTRFS_FILE_DEFAULT
btrfs-mount.sh
btrfs filesystem resize max $DATA_ROOT_DEFAULT

dockerd --tls=false --host=tcp://0.0.0.0:2375
