#!/bin/sh

set -x

# dockerd start
dockerd > /var/log/dockerd.log 2>&1 &
sleep 2

# Install ddev.
export DDEV_VERSION=v1.24.2
wget https://raw.githubusercontent.com/ddev/ddev-gitlab-ci/refs/heads/main/ddev-install.sh
ash ddev-install.sh
rm -rf ddev-install.sh

# Download images.
addgroup ddev docker
sudo -u ddev /usr/local/bin/ddev debug download-images

# TODO Remove ddev.

# dockerd cleanup (remove the .pid file as otherwise it prevents
# dockerd from launching correctly inside sys container)
kill $(cat /var/run/docker.pid)
kill $(cat /run/docker/containerd/containerd.pid)
rm -f /var/run/docker.pid
rm -f /run/docker/containerd/containerd.pid
