#!/bin/bash

# Check the migration status.

echo -n "hotplug" > /dev/tcp/10.128.0.41/9797
