#!/bin/bash

help()
{
        echo "Usage: $1 -o <op> -s <socket> -t <template dir> -d <host:port>"
        echo "op: migrate, migrate_cap, add_netdev, save, status, powerdown or quit"
}

enable_bypass_shared_memory()
{
        local socket=$1
        echo '{"execute":"qmp_capabilities"}{"execute":"migrate-set-capabilities", "arguments":{"capabilities": [{"capability":"bypass-shared-memory", "state":true}]}}' | nc -U $socket
}

get_migration_caps()
{
        local socket=$1
        echo '{"execute":"qmp_capabilities"}{"execute":"query-migrate-capabilities"}' | nc -U $socket | tail -n 1 | sed 's/{/\n{/g'
}

save_vm()
{ 
        local socket=$1
        local tdir=$2
        echo '{"execute":"qmp_capabilities"}{"execute":"migrate", "arguments":{"uri":"exec:cat' '>' "${tdir}/state\"}}" | nc -U $socket
}

get_migration_status()
{
        local socket=$1
        echo '{"execute":"qmp_capabilities"}{"execute":"query-migrate"}' | nc -U $socket
}

get_vm_status()
{
        local socket=$1
        echo '{"execute":"qmp_capabilities"}{"execute":"query-status"}' | nc -U $socket
}

quit()
{
        local socket=$1
        echo '{"execute":"qmp_capabilities"}{"execute":"quit"}' | nc -U $socket
}

powerdown()
{
        local socket=$1
        echo '{"execute":"qmp_capabilities"}{"execute":"system_powerdown"}' | nc -U $socket
}

add_netdev()
{
        local socket=$1
        echo '{"execute":"qmp_capabilities"}{"execute":"netdev_add","arguments":{"type":"tap", "ifname":"qtap0", "id":"mytap", "script":"no", "downscript":"no", "vhost":"on"}}' | nc -U $socket
        echo '{"execute":"qmp_capabilities"}{"execute":"device_add","arguments":{"driver":"virtio-net", "netdev":"mytap", "id":"vnic"}}' | nc -U $socket
}

migrate()
{
        local socket=$1
        local dest=$2
        echo '{"execute": "qmp_capabilities"}{"execute": "migrate", "arguments": {"uri": "tcp:'"$dest\"}}" | nc -U $socket
}


[[ $# -eq 0 ]] && help $0 && exit 1

op=""
socket=""
tdir="/run/vm"
dest=""

while getopts "o:s:t:d:h" opt; do
        case ${opt} in
                o)
                        op=$OPTARG ;;
                s)
                        socket=$OPTARG ;;
                t)
                        tdir=$OPTARG ;;
                d)
                        dest=$OPTARG ;;
                h)
                        help $0
                        exit 1
                        ;;
        esac
done
shift $(( OPTIND - 1 ))

if [[ $op == "save" ]]; then
        enable_bypass_shared_memory $socket
        get_migration_caps $socket
        save_vm $socket $tdir
elif [[ $op == "status" ]]; then
        get_migration_status $socket
        get_vm_status $socket
elif [[ $op == "quit" ]]; then
        quit $socket
elif [[ $op == "powerdown" ]]; then
        powerdown $socket
elif [[ $op == "add_netdev" ]]; then
        add_netdev $socket
elif [[ $op == "migrate" ]]; then
        migrate $socket $dest
elif [[ $op == "migrate_cap" ]]; then
        get_migration_caps $socket
else
        echo "No such operation: $op"
        echo "- migrate"
        echo "- migrate_cap"
        echo "- add_netdev"
        echo "- save"
        echo "- status"
        echo "- powerdown"
        echo "- quit"
fi
