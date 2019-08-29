#!/bin/bash

# Set the the tap device.
tunctl -t qtap0 -u `whoami`
brctl addif br0 qtap0
ifconfig qtap0 up
