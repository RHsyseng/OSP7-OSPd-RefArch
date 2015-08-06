#!/bin/bash

source /home/stack/stackrc
env | grep OS_

heat stack-delete overcloud
sleep 30

for i in $(ironic node-list | awk ' /power/ { print $2 } ' );
do
	openstack baremetal introspection status $i -f value -c finished
	openstack baremetal introspection status $i -f value -c error
	ironic node-set-power-state $i off
	ironic node-delete $i
done
sleep 30
sudo rm /var/lib/ironic-discoverd/discoverd.sqlite  # must be deleted as root
ls -al /var/lib/ironic-discoverd/discoverd.sqlite
sudo systemctl restart openstack-ironic-discoverd
sudo systemctl status openstack-ironic-discoverd
ironic node-list
