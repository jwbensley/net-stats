#!/bin/bash

# This script will spread the interface queue interrupts evenly across the
# available CPU cores/threads (if there are enough cores/threads).
# This script will not use core 0. With N queue IRQs and M CPUs (where N
# is greater than M), after the first M IRQs are mapped to sequential cores
# the remaining IRQs up to N will all be mapped to core 1.
#
# A remake of https://gist.github.com/pavel-odintsov/9b065f96900da40c5301
# By jwbensley@gmail.com / https://github.com/jwbensley

if [ -z "$1" ]
then
    echo ''
    echo 'usage: sudo $0 [network-interface]'
    echo ''
    echo 'e.g. sudo $0 eth0'
    echo ''
    echo 'Adjusts irq balance for interface queues'
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


n=0
for irq in `awk -F "[:]" "/$IF/"'{print $1}' /proc/interrupts`
do
    f="/proc/irq/$irq/smp_affinity"
    test -r "$f" || continue # True is readable
    cpu=$[$ncpus - ($n % $ncpus) - 1]
    if [ $cpu -gt 0 ]
    then
        mask=`printf %x $[2 ** $cpu]`
        echo "Assign SMP affinity: $IF queue $n, irq $irq, cpu $cpu, mask 0x$mask"
        echo "$mask" > "$f"
        let n+=1
    elif [ $cpu -eq 0 ]
    then
        let n-=1
        cpu=$[$ncpus - ($n % $ncpus) - 1]
        mask=`printf %x $[2 ** $cpu]`
        echo "Assign SMP affinity: $IF queue $n, irq $irq, cpu $cpu, mask 0x$mask"
        echo "$mask" > "$f"
    fi
done

# To view all IRQs that are pinned to the same core, core 12 for example is mask 0x0800;
# for irq in `ls -1 /proc/irq/`; do awk "/$irq:/"'{printf "%s ", $NF}' /proc/interrupts; sudo cat /proc/irq/$irq/smp_affinity; done | grep 0800
