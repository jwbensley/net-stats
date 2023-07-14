#!/bin/bash

# This script prints the Tx/Rx rate (delta) every 1 second.
# The stats come from ethtool (the NIC driver).
# By jwbensley@gmail.com / https://github.com/jwbensley

set -eu


INTERVAL="1" # update interval in seconds

if [ -z "$1" ]; then
    echo ''
    echo 'usage: $0 [network-interface]'
    echo ''
    echo 'e.g. $0 eth0'
    echo ''
    echo 'Shows NIC port bytes and packets per second'
    exit
fi

IF=$1


which ethtool > /dev/null
if [[ $? -ne 0 ]]
then
    echo "ethtool is required, please install it"
    exit 1
fi

use_bc=0
which bc > /dev/null
if [[ $? -eq 0 ]]
then
    use_bc=1
else
    use_bc=0
fi


while true
do

    RX_BYTES_1=$(sudo ethtool -S $IF | grep -m 1 -E "^ +rx_bytes:" | awk '{print $NF}')
    RX_PPS_1=$(sudo ethtool -S $IF | grep -m 1 -E "^ +rx_packets:" | awk '{print $NF}')
    TX_BYTES_1=$(sudo ethtool -S $IF | grep -m 1 -E "^ +tx_bytes:" | awk '{print $NF}')
    TX_PPS_1=$(sudo ethtool -S $IF | grep -m 1 -E "^ +tx_packets:" | awk '{print $NF}')

    sleep $INTERVAL

    RX_BYTES_2=$(sudo ethtool -S $IF | grep -m 1 -E "^ +rx_bytes:" | awk '{print $NF}')
    RX_PPS_2=$(sudo ethtool -S $IF | grep -m 1 -E "^ +rx_packets:" | awk '{print $NF}')
    TX_BYTES_2=$(sudo ethtool -S $IF | grep -m 1 -E "^ +tx_bytes:" | awk '{print $NF}')
    TX_PPS_2=$(sudo ethtool -S $IF | grep -m 1 -E "^ +tx_packets:" | awk '{print $NF}')

    RX_BYTES=$(expr $RX_BYTES_2 - $RX_BYTES_1)
    RX_PPS=$(expr $RX_PPS_2 - $RX_PPS_1)
    TX_BYTES=$(expr $TX_BYTES_2 - $TX_BYTES_1)
    TX_PPS=$(expr $TX_PPS_2 - $TX_PPS_1)

    if [ $use_bc -eq 1 ]
    then
        RX_GBPS=$(echo "scale=2; $RX_BYTES * 8 / 1000 / 1000 / 1000 "| bc)
        TX_GBPS=$(echo "scale=2; $TX_BYTES * 8 / 1000 / 1000 / 1000 "| bc)
    else
        RX_GBPS=$(expr $RX_BYTES \* 8 / 1000 / 1000 / 1000)
        TX_GBPS=$(expr $TX_BYTES \* 8 / 1000 / 1000 / 1000)
    fi    

    echo "$IF: TX $TX_GBPS Gbps ($TX_PPS pkts/s) RX $RX_GBPS Gbps ($RX_PPS pkts/s)"
done
