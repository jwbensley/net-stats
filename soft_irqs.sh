#!/bin/bash
set -u

# Print NET_TX and NET_RX soft IRQ rate (delta) ever 1 second.
# By jwbensley@gmail.com / https://github.com/jwbensley


INTERVAL="1" # update interval in seconds

core=1
declare -a NET_TX_PREV
declare -a NET_RX_PREv

echo -e "CPU\tNET_TX\tNET_RX"

# nproc won't show cores excluded by isolcpu/nohz_full/rcu_nocbs
#ncpus=`nproc
ncpus=`grep -ciw ^processor /proc/cpuinfo`
test "$ncpus" -ge 1 || exit 1
echo "CPUs: $ncpus"

while [ $core -le $ncpus ]
do
    let col=core+1
    #grep "NET_TX" /proc/softirqs |  awk -v col="$col" '{printf "%d ", $col}'
    NET_TX_PREV[$core]=`grep "NET_TX" /proc/softirqs |  awk -v col="$col" '{printf "%d ", $col}'`
    NET_RX_PREV[$core]=`grep "NET_RX" /proc/softirqs |  awk -v col="$col" '{printf "%d ", $col}'`
    echo -e "CPU$core\t${NET_TX_PREV[$core]}\t${NET_RX_PREV[$core]}"
    let core=core+1
done
echo ""

declare -a NET_TX_CUR
declare -a NET_RX_CUR
declare -a NET_TX_DIFF
declare -a NET_RX_DIFF

while true
do

    core=1
    while [ $core -le $ncpus ]
    do
        let col=core+1
        #grep "NET_TX" /proc/softirqs |  awk -v col="$col" '{printf "%d ", $col}'
        NET_TX_CUR[$core]=`grep "NET_TX" /proc/softirqs |  awk -v col="$col" '{printf "%d ", $col}'`
        NET_RX_CUR[$core]=`grep "NET_RX" /proc/softirqs |  awk -v col="$col" '{printf "%d ", $col}'`
        NET_TX_DIFF[$core]=`expr ${NET_TX_CUR[$core]} - ${NET_TX_PREV[$core]}`
        NET_RX_DIFF[$core]=`expr ${NET_RX_CUR[$core]} - ${NET_RX_PREV[$core]}`
        NET_TX_PREV[$core]=${NET_TX_CUR[$core]}
        NET_RX_PREV[$core]=${NET_RX_CUR[$core]}
        echo -e "CPU$core\t${NET_TX_DIFF[$core]}\t${NET_RX_DIFF[$core]}"
        let core=core+1
    done

    echo ""

    sleep 1

done
