#!/bin/bash

# Check the migration status.

for (( ;; ))
do
	echo '{"execute": "qmp_capabilities"} {"execute": "query-status"}' | nc -U "/tmp/qmp-socket" 2> /dev/null
	if [[ $? -eq 0 ]]
	then
    #echo "Done preparing"
		echo -n "prepared" > /dev/tcp/10.128.0.42/3535
		#echo "inmigrate set"
		break
	fi
done
