#!/bin/bash

# Switch vfio nic.

if [[ $# != 2 ]]; then
  echo "Usage: $0 <DESTINATION IP ADDRESS> <PORT>"
  exit 1
fi

destination_IP_address=$1
port=$2

# Unplug NIC 
bash hot_switch_vfio_nic.sh unplug

# Migrate the VM
bash migrate.sh $destination_IP_address $port /tmp/qmp-socket
