#!/bin/bash

# List number of physical CPUs, logical CPUs and number of cores per physical CPU.
# Original: https://unix.stackexchange.com/questions/33450/checking-if-hyperthreading-is-enabled-or-not/33509#33509
# Bastardised by jwbensley@gmail.com / https://github.com/jwbensley

CPUFILE=/proc/cpuinfo
test -f $CPUFILE || exit 1

echo "Physical CPUs: $(grep "physical id" $CPUFILE | sort -u | wc -l)"
echo "Logical cores: $(grep "core id" $CPUFILE | sort -u | wc -l)"
echo "CPU count:     $(grep "processor" $CPUFILE | wc -l)"