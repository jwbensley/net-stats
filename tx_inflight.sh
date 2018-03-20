#!/bin/bash

# This script prints the number of in-flight packets in each of the NIC Tx queues.
# By jwbensley@gmail.com / https://github.com/jwbensley

if [ -z "$1" ]
then
    echo ''
    echo 'usage: sudo $0 [network-interface]'
    echo ''
    echo 'e.g. sudo $0 eth0'
    echo ''
    echo 'Displays Tx queue in-flight packet count'
    exit
fi

IF="$1"

while true
do

    for file in /sys/class/net/$IF/queues/tx-*/byte_queue_limits/
    do
       echo "$file: `cat $file/inflight`"
    done

    echo ""
    sleep 1

done
