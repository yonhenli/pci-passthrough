#!/bin/bash

# Setup virtual function.

if [[ $# != 4 ]]; then
  echo "Usage: $0 <NUMBER OF VIRTUAL FUNCTIONS> <INTERFACE> <VIRTUAL FUNCTION INDEX> <MAC ADDRESS>"
  exit 1
fi

number_of_virtual_functions=$1
interface=$2
virtual_function_index=$3
mac_address=$4

# Create virtual function
echo $number_of_virtual_functions > /sys/class/net/$interface/device/sriov_numvfs

# Setup MAC address for the virtual function
ip link set $interface vf $virtual_function_index mac $mac_address

# Reinsert igbvf kernel module
rmmod igbvf
modprobe igbvf

