#!/bin/bash

IFS_BAK=${IFS}
IFS="
"
if [ -z $1 ];
then
	dl=0
	service_list=$(systemctl list-units --type=service | grep "active" | grep -v '@' | awk '{print $1}' | sed -e 's/.service//')
	descr_list=(`systemctl list-units --type=service | grep "active" | grep -v '@' | awk '{$1=$2=$3=$4=""; print $0}'`)
	echo -n '{"data":['
	for s in ${service_list}
		do 
			echo -n "{\"{#SYSTEMD.SERVICE.NAME}\": \"$s\",\"{#SYSTEMD.SERVICE.DESCRIPTION}\": \"${descr_list[$dl]}\"},";
			((dl++));
		done | sed -e 's:\},$:\}:';
	echo -n ']}'

else

	dl=0
	service_list=$(systemctl list-units --type=service | grep "active" | grep '@' | awk '{print $1}' | sed -e 's/.service//')
	descr_list=(`systemctl list-units --type=service | grep "active" | grep '@' | awk '{$1=$2=$3=$4=""; print $0}'`)
	echo -n '{"data":['
	for s in ${service_list}
		do 
			echo -n "{\"{#SYSTEMD.SERVICE.FULLNAME.MI}\": \"$s\",\"{#SYSTEMD.SERVICE.DESCRIPTION.MI}\": \"${descr_list[$dl]}\",\"{#SYSTEMD.SERVICE.INSTANCE.MI}\": \"${s#*@}\",\"{#SYSTEMD.SERVICE.NAME.MI}\": \"${s%@*}\"},";
			((dl++));
	done | sed -e 's:\},$:\}:';
	echo -n ']}'

fi

IFS=${IFS_BAK}