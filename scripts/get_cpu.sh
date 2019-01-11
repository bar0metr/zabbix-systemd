#!/bin/bash

if [ -z $2 ];
then
	SYSTEM_PRE=$(date +%s%N)
	SERVICE_PRE=$(cat /sys/fs/cgroup/cpu,cpuacct/system.slice/$1.service/cpuacct.usage)
	sleep 1
	SYSTEM=$(date +%s%N)
	SERVICE=$(cat /sys/fs/cgroup/cpu,cpuacct/system.slice/$1.service/cpuacct.usage)
	SERVICE_DELTA=$((SERVICE-SERVICE_PRE));
	SYSTEM_DELTA=$((SYSTEM-SYSTEM_PRE))
	awk "BEGIN {printf \"%.2f\",${SERVICE_DELTA}/${SYSTEM_DELTA}*100}"
else
	SERVICENAME=$(echo $1 | sed 's!-!\\x2d!')
	SYSTEM_PRE=$(date +%s%N)
	SERVICE_PRE=$(cat /sys/fs/cgroup/cpu,cpuacct/system.slice/system-$SERVICENAME.slice/$1@$2.service/cpuacct.usage)
	sleep 1
	SYSTEM=$(date +%s%N)
	SERVICE=$(cat /sys/fs/cgroup/cpu,cpuacct/system.slice/system-$SERVICENAME.slice/$1@$2.service/cpuacct.usage)
	SERVICE_DELTA=$((SERVICE-SERVICE_PRE))
	SYSTEM_DELTA=$((SYSTEM-SYSTEM_PRE))
	awk "BEGIN {printf \"%.2f\",${SERVICE_DELTA}/${SYSTEM_DELTA}*100}"
fi
