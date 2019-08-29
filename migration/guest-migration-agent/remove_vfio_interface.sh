#!/bin/bash

# Check the migration status.

sudo ifenslave -c bond0 ens3
echo "-ens4" >"/sys/class/net/bond0/bonding/slaves"; 
ifconfig ens4 down
