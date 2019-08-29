#!/bin/bash

# Check if vfio interface is up.


for (( ; ; ))
do
  if (( $(ls -l /sys/class/net/ | grep ens4 | wc -l) == 1 ))
  then
     #echo "interface recognized"
     for (( ; ; ))
     do
        if (( $(cat /sys/class/net/ens4/operstate | grep up | wc -l) == 1 ))
        then
          #echo "interface up"
          break
        fi
     done
     break
  fi 
done

