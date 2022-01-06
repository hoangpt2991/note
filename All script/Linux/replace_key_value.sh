#!/bin/bash
#target_file=$2
properties_file=$1
cd /root/linux_script
while IFS= read -r LINE || [[ "$LINE" ]]; do
 if [[ "${LINE::1}" != "#" ]] && [[ $LINE =~ [^[:space:]] ]];
	then
    echo "$LINE" 	
		KEY=$(echo $LINE | cut -d'=' -f 1)
		VALUE=$(echo $LINE | cut -d'=' -f 2)
    echo field1:$KEY 
    echo field2:$VALUE 
    sed -i "s|$KEY|$VALUE|g" *.xml
	fi
done < $properties_file
sed -i 's|\r||g'  $target_file

