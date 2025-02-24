#!/bin/sh

btrfs-mount.sh

dockerd --tls=false --host=tcp://0.0.0.0:2375
