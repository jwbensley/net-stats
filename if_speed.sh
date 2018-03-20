#!/bin/bash

# This script prints the Tx/Rx rate (delta) every 1 second.
# The stats come from the Kernel.
# Put an interface into promiscuous mode with:
# $ sudo ifconfig eth3 promisc
# Disable promiscuous mode with:
# $ sudo ifconfig eth3 -promisc
# A variation of https://gist.github.com/pavel-odintsov/bc287860335e872db9a5
# By jwbensley@gmail.com / https://github.com/jwbensley


INTERVAL="1" # update interval in seconds

if [ -z "$1" ]; then
    echo ''
    echo 'usage: $0 [network-interface]'
    echo ''
    echo 'e.g. $0 eth0'
    echo ''
    echo 'Shows interface bytes and packets per second'
    exit
fi

IF=$1

while true
do

    RX_BYTES_1=`cat /sys/class/net/$IF/statistics/rx_bytes`
    RX_PPS_1=`cat /sys/class/net/$IF/statistics/rx_packets`
    TX_BYTES_1=`cat /sys/class/net/$IF/statistics/tx_bytes`
    TX_PPS_1=`cat /sys/class/net/$IF/statistics/tx_packets`

    sleep $INTERVAL

    RX_BYTES_2=`cat /sys/class/net/$IF/statistics/rx_bytes`
    RX_PPS_2=`cat /sys/class/net/$IF/statistics/rx_packets`
    TX_BYTES_2=`cat /sys/class/net/$IF/statistics/tx_bytes`
    TX_PPS_2=`cat /sys/class/net/$IF/statistics/tx_packets`

    RX_BYTES="$(expr $RX_BYTES_2 - $RX_BYTES_1)"
    RX_PPS="$(expr $RX_PPS_2 - $RX_PPS_1)"
    TX_BYTES="$(expr $TX_BYTES_2 - $TX_BYTES_1)"
    TX_PPS="$(expr $TX_PPS_2 - $TX_PPS_1)"

    bc -v > /dev/null 2>&1
    if [[ $? -eq 0 ]]
    then
        RX_GBPS=$(echo "scale=2; $RX_BYTES * 8 / 1000 / 1000 / 1000 "| bc)
        TX_GBPS=$(echo "scale=2; $TX_BYTES * 8 / 1000 / 1000 / 1000 "| bc)
    else
        RX_GBPS=$(expr $RX_BYTES \* 8 / 1000 / 1000 / 1000)
        TX_GBPS=$(expr $TX_BYTES \* 8 / 1000 / 1000 / 1000)
    fi    

    echo "$IF: TX $TX_GBPS Gbps ($TX_PPS pkts/s) RX $RX_GBPS Gbps ($RX_PPS pkts/s)"
done
