#!/bin/bash

# Boot up the VM with the assigned NIC and tap device.

# Input parameters.
if [[ $# != 3 ]]; then
  echo "Usage: $0 <VCPU> <MEMORY> <VM IMAGE>"
  #<NUMBER OF VIRTUAL FUNCTIONS> <INTERFACE> <VIRTUAL_FUNCTION_INDEX> <MAC ADDRESS>
  exit 1
fi

vcpu=$1
memory=$2
vm_image=$3
#number_of_virtual_functions=1
#interface="enp7s0f1"
#virtual_function_index=0
#mac_address="00:25:90:d8:aa:ee"

# Create virtual functions
#./setup_virtual_function.sh $number_of_virtual_functions $interface $virtual_function_index $mac_address

# Setup passthrough NIC
./setup_vfio_nic.sh

# Run VM in background
#./run_vm_nic_bonding.sh $vcpu $memory $vm_image &
./run_source_vm.sh &
