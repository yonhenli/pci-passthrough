#!/bin/bash

run()
{
        local i=$1
        local vcpu=$2
        local ram=$3
        local img=$4
        local port=$(( i + 8800 )) 
        local sdir="/tmp"

        $qemu -machine pc,accel=kvm,kernel_irqchip=on,nvdimm=on \
              -cpu host,host-cache-info=on \
              -smp ${vcpu},cores=${vcpu},threads=1,sockets=1 \
              -m   ${ram},slots=4,maxmem=10240M\
              -drive file=${img},if=virtio \
              -netdev tap,ifname=qtap0,id=mytap,script=no,downscript=no,vhost=on\
              -device virtio-net,netdev=mytap\
              -qmp unix:${sdir}/qmp-${i}.sock,server,nowait \
              -serial telnet:127.0.0.1:${port},server,nowait \
              -parallel none \
              -serial none \
              -vga none \
              -nographic \
              -nodefaults
}

run_by_memory_backend()
{
        local i=$1
        local vcpu=$2
        local ram=$3
        local img=$4
        local tdir=$5
        local max_vcpu=$(( vcpu - 1 ))
        local port=$(( i + 8800 ))
        local sdir="/tmp"

        $qemu -machine pc,accel=kvm,kernel_irqchip=on,nvdimm=on \
              -cpu host,host-cache-info=on \
              -smp ${vcpu},cores=${vcpu},threads=1,sockets=1 \
              -m   ${ram},slots=4,maxmem=10240M\
              -object memory-backend-file,id=mem0,size=${ram},mem-path=${tdir}/memory,share=on \
              -numa node,nodeid=0,cpus=0-${max_vcpu},memdev=mem0 \
              -drive file=${img},if=virtio \
              -netdev tap,ifname=qtap0,id=mytap,script=no,downscript=no,vhost=on\
              -device virtio-net,netdev=mytap\
              -qmp unix:${sdir}/qmp-${i}.sock,server,nowait \
              -serial telnet:127.0.0.1:${port},server,nowait \
              -parallel none \
              -serial none \
              -vga none \
              -nographic \
              -nodefaults
}

run_by_template()
{
        local i=$1
        local vcpu=$2
        local ram=$3
        local img=$4
        local tdir=$5
        local max_vcpu=$(( vcpu - 1 ))
        local port=$(( i + 8800 )) 
        local sdir="/tmp"

        $qemu -machine pc,accel=kvm,kernel_irqchip=on,nvdimm=on \
              -cpu host,host-cache-info=on \
              -smp ${vcpu},cores=${vcpu},threads=1,sockets=1 \
              -m   ${ram},slots=4,maxmem=10240M\
              -object memory-backend-file,id=mem0,size=${ram},mem-path=${tdir}/memory,share=off \
              -numa node,nodeid=0,cpus=0-${max_vcpu},memdev=mem0 \
              -drive file=${img},if=virtio \
              -netdev tap,ifname=qtap0,id=mytap,script=no,downscript=no,vhost=on\
              -device virtio-net,netdev=mytap\
              -qmp unix:${sdir}/qmp-${i}.sock,server,nowait \
              -serial telnet:127.0.0.1:${port},server,nowait \
              -incoming "exec:cat ${tdir}/state" \
              -parallel none \
              -serial none \
              -vga none \
              -nographic \
              -nodefaults
}

help()
{
        echo "Usage: $1 -o <op> -v <vcpu> -r <ram size> -m <image> -t <template dir> -i <index> -h"
        echo "op: reg, backed_memory or template."
}

if [[ $# -eq 0 ]]; then
        help $0
        exit 1
fi

op=""
vcpu=0
ram=0
img=""
tdir=""
idx=0
qemu=$(which qemu-system-x86_64)

while getopts "o:v:r:m:t:i:h" opt; do
        case ${opt} in
                o)
                        op=$OPTARG ;;
                v)
                        vcpu=$OPTARG ;;
                r)
                        ram=$OPTARG ;;
                m)
                        img=$OPTARG ;;
                t)
                        tdir=$OPTARG ;;
                i)
                        idx=$OPTARG ;;
                h)
                        help $0
                        exit 1
                        ;;
        esac
done
shift $(( OPTIND - 1 ))

if [[ $op == "reg" ]]; then
        run $idx $vcpu $ram $img &
elif [[ $op == "backed_memory" ]]; then
        [[ ! -d $tdir ]] && echo "$tdir does not exist" && exit 1
        run_by_memory_backend $idx $vcpu $ram $img $tdir &
elif [[ $op == "template" ]]; then
        [[ ! -d $tdir ]] && echo "$tdir does not exist" && exit 1
        run_by_template $idx $vcpu $ram $img $tdir &
else
        echo "No such operation: $op"
        echo "- reg"
        echo "- backed_memory"
        echo "- template"
fi
