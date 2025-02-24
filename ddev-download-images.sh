#!/bin/sh

set -x

# Init docker.
btrfs-mount.sh
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

btrfs-umount.sh
