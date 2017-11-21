#!/bin/bash

#CPU_LOAD=$(ssh -i "/home/gimeno/.ssh/id_rsa.pub" mgimeno@$1 
CPU_LOAD=$(grep 'cpu ' /proc/stat | awk '{cpu_usage=($2+$4)*100/($2+$4+$5)} END {print cpu_usage}')
TEST=$(echo "SUCCESS")
if [ -z "$TEST" ]; then 
  echo "Something is really wrong with that horse."
  exit 2
fi

#TEST=$(ssh mgimeno@$1 echo "SUCCESS")

#if [ -z "$TEST" ]; then 
#  echo "No SSH access."
#  exit 2
#fi

if [ -z "$CPU_LOAD" ]; then 
  echo "could not compute CPU load."
  exit 2
fi
if (( $(echo "$CPU_LOAD > 99.0" | bc -l) )); then
  echo "CPU average load $CPU_LOAD % > 99.0%"
  exit 2
elif (( $(echo "$CPU_LOAD > 85.0" | bc -l) )); then
  echo "CPU average load $CPU_LOAD % > 85.0%"
  exit 1
else
  echo "CPU average load $CPU_LOAD % < 85.0%"
  exit 0
fi

