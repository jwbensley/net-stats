#!/bin/bash

# This script displays the interface Rx queue to CPU mapping (RPS).
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
    echo 'Displays Rx queue to CPU mapping (RPS)'
    exit
fi

IF="$1"


echo "Existing Rx queue affinity for $IF:"
tx_count=`find /sys/class/net/$IF/queues/ -maxdepth 1 -type d -name "rx*" -printf '.' | wc -c`

if [ $tx_count -gt 0 ]
then

    let tx_count=tx_count-1 # 8 queues would be 7 down to 0
    for i in `seq 0 $tx_count`
    do
        echo -n "Tx$i: "
        cat /sys/class/net/$IF/queues/rx-$i/rps_cpus
    done
fi
