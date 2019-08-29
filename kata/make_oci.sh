#!/bin/bash

# In OCI bundile, there are two files.
# 1. config.json
# 2. rootfs

oci="/tmp/oci"
rootfs="$oci/rootfs"
mkdir -p "$rootfs"
cd "$oci"

# Note we customize the runtime spec (config.json).
kata-runtime spec

# Create Ubuntu OCI bundle by docker
sudo docker export $(sudo docker create ubuntu) | tar -C "$rootfs" -xvf -
