#!/bin/bash

btrfs-mount.sh

dockerd --tls=false --host=unix:///var/run/docker.sock,tcp://0.0.0.0:2375
