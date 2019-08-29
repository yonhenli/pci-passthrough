#!/bin/bash

# Check the migration status.

/sbin/modprobe bonding mode=1 fail_over_mac=1
/sbin/ifenslave bond0 ens4 ens3
