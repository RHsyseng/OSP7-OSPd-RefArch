#!/bin/bash

set -x

# create the fence device on all controllers
for i in $(nova list | awk ' /controller/ { print $12 } ' | cut -f2 -d=)
do 
	ssh -l heat-admin $i 'sudo pcs stonith create $(hostname -s)-ipmi fence_ipmilan pcmk_host_list=$(hostname -s) ipaddr=$(sudo ipmitool lan print 1 | awk " /IP Address / { print $4 } ") login=root passwd=100Mgmt- lanplus=1 cipher=1 op monitor interval=60s'
done

# configure node to not fence itself
for i in $(nova list | awk ' /controller/ { print $12 } ' | cut -f2 -d=)
do 
	ssh -l heat-admin $i 'sudo pcs constraint location $(hostname -s)-ipmi avoids $(hostname -s)'
	ssh -l heat-admin $i 'sudo pcs stonith show $(hostname -s)-ipmi'
done

# execute after all stonith devices are enabled
for i in $(nova list | awk ' /controller/ { print $12 } ' | cut -f2 -d= | head -n 1)
do
	ssh -l heat-admin $i 'sudo pcs property set stonith-enabled=true'
	ssh -l heat-admin $i 'sudo pcs property show'
done
