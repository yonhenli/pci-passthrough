#!/bin/bash

# Check the migration status.

for (( ; ; ))
do
if (( $(./check_migration_status.sh /tmp/qmp-socket | grep complete | wc -l) == 1 )) 
then
  echo -n "Done" > /dev/tcp/10.128.0.41/9797
  #echo "migration complete"
  break
elif (( $(./check_migration_status.sh /tmp/qmp-socket | grep failed | wc -l) == 1 ))
then
  echo "migration failed"
  break
fi
done
