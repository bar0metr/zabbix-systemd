#!/bin/bash
if [ -z $3 ];
then
	MEMORY=$(cat /sys/fs/cgroup/memory/system.slice/$1.service/memory.stat | grep -w $2)
else
	SERVICENAME=$(echo $1 | sed 's!-!\\x2d!')
	MEMORY=$(cat /sys/fs/cgroup/memory/system.slice/system-$SERVICENAME.slice/$1@$3.service/memory.stat | grep -w $2)	
fi
echo ${MEMORY#* }