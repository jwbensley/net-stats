#!/bin/bash

# This script displays the interface queue interrupt mapping across the
# available CPU cores.
# A remake of https://gist.github.com/pavel-odintsov/9b065f96900da40c5301
# By jwbensley@gmail.com / https://github.com/jwbensley

if [ -z "$1" ]
then
    echo ''
    echo 'usage: sudo $0 [network-interface]'
    echo ''
    echo 'e.g. sudo $0 eth0'
    echo ''
    echo 'Displays irq mapping for interface queues'
    exit
fi

IF="$1"


if [[ `id -u` -ne 0 ]]
then
    echo "Must be root to run this script!"
    exit 1
fi


# nproc won't show cores excluded by isolcpu/nohz_full/rcu_nocbs
#ncpus=`nproc`
ncpus=`grep -ciw ^processor /proc/cpuinfo`
test "$ncpus" -ge 1 || exit 1
echo "CPUs: $ncpus"


echo "Existing irq affinity for $IF:"
for irq in `awk -F "[:]" "/$IF/"'{print $1}' /proc/interrupts`
do
    awk "/$irq:/"'{printf "%s ", $NF}' /proc/interrupts
    cat /proc/irq/$irq/smp_affinity
done


# To view all IRQs that are pinned to the same core, core 12 for example is mask 0x0800;
# for irq in `ls -1 /proc/irq/`; do awk "/$irq:/"'{printf "%s ", $NF}' /proc/interrupts; sudo cat /proc/irq/$irq/smp_affinity; done | grep 0800