#!/bin/bash

set -x

if [ `id -ng` == root ]
then 
	echo -e "ERROR: running script as root"
	exit 113
fi

source ~/stackrc
env | grep OS_

# register and introspect systems

# create node JSON file
cp /pub/projects/rhos/kilo/scripts/jliberma/new/instackenv.json.example ~/instackenv.json

# register the nodes with ironic
openstack baremetal import --json ~/instackenv.json
openstack baremetal list

# assign a kernel and ramdisk to the nodes
openstack baremetal configure boot

# introspect hatrdware attributes of the nodes
openstack baremetal introspection bulk start
openstack baremetal introspection bulk status

# watch introspection
sudo journalctl -l -u openstack-ironic-discoverd -u openstack-ironic-discoverd-dnsmasq -u openstack-ironic-conductor

# create profiles and flavors

# Create the default flavor for baremetal deployments.
openstack flavor create --id auto --ram 4096 --disk 40 --vcpus 1 baremetal
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" baremetal

# install ahc-tools
sudo yum install -y ahc-tools

# create the configuration file
sudo cp /etc/ironic-discoverd/discoverd.conf /etc/ahc-tools/ahc-tools.conf 
sudo sed -i 's/\[discoverd/\[ironic/' /etc/ahc-tools/ahc-tools.conf
sudo chmod 0600 /etc/ahc-tools/ahc-tools.conf
sudo cat /etc/ahc-tools/ahc-tools.conf
sudo cp /pub/projects/rhos/kilo/scripts/jliberma/new/edeploy/* /etc/ahc-tools/edeploy/
cat /etc/ahc-tools/edeploy/{*.specs,state}

# create and flavors for each role 
for i in ceph control compute
do
	openstack flavor create --id auto --ram 4096 --disk 40 --vcpus 1 $i 
	openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="$i" $i
done

openstack flavor list

# assign flavors to ironic nodes by profile
sudo ahc-match

# view the results
for i in $(ironic node-list | awk ' /available/ { print $2 } ')
do 
	ironic node-show $i | grep capabilities 
done

# configure overcloud nameserver
neutron subnet-update $(neutron subnet-list | awk ' /192.0.2/ { print $2 } ') --dns-nameserver 10.19.143.247

# copy network isolation files into place
cp /pub/projects/rhos/kilo/scripts/jliberma/new/network-environment.yaml.example ~/network-environment.yaml
mkdir ~/nic-configs
cp /pub/projects/rhos/kilo/scripts/jliberma/new/nic-configs/*.yaml ~/nic-configs/

# copy storage environment templates into place
mkdir ~/templates
cp -rp /usr/share/openstack-tripleo-heat-templates/ ~/templates
cp -b /pub/projects/rhos/kilo/scripts/jliberma/new/templates/ceph.yaml ~/templates/openstack-tripleo-heat-templates/puppet/hieradata/ceph.yaml

# TODO: test this with trown when https://bugzilla.redhat.com/show_bug.cgi?id=1231214 hits

# get deployment plan name
#uuid=$(openstack management plan list | awk ' /overcloud/ { print $2 } ')
#echo $uuid
#openstack management plan show $uuid

# to verify clean environment before updating after a failed deployment attempt
ironic node-list
nova list --all-tenants
heat stack-list
#for i in $(ironic node-list | awk ' /power on/ { print $2 } '); do ironic node-set-power-state $i off; done

# deploy the overcloud
# defaults to vxlan
#openstack overcloud deploy -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml -e /home/stack/network-environment.yaml --plan $uuid --control-flavor control --compute-flavor compute --ceph-storage-flavor ceph --ntp-server 10.16.255.2 --control-scale 3 --compute-scale 4 --ceph-storage-scale 4 --block-storage-scale 0 --swift-storage-scale 0 -t 90

# no ahc profile matching
#openstack overcloud deploy -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml -e /home/stack/network-environment.yaml --plan $uuid --ntp-server 10.16.255.2 --control-scale 3 --compute-scale 4 --ceph-storage-scale 0 --block-storage-scale 0 --swift-storage-scale 0 --neutron-public-interface nic2 -t 90

# no network iso / no ahc profile matching
#openstack overcloud deploy --plan $uuid --ntp-server 10.16.255.2 --control-scale 1 --compute-scale 1 --ceph-storage-scale 0 --block-storage-scale 0 --swift-storage-scale 0 --neutron-public-interface nic2 --libvirt-type kvm -t 45

# plan based with ahc profiles, ceph, and nics
#openstack overcloud deploy -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml -e /home/stack/network-environment.yaml --control-flavor control --compute-flavor compute --ceph-storage-flavor ceph --ntp-server 10.16.255.2 --control-scale 3 --compute-scale 4 --ceph-storage-scale 4 --block-storage-scale 0 --swift-storage-scale 0 -t 90 --templates /home/stack/templates/openstack-tripleo-heat-templates/ -e /usr/share/openstack-tripleo-heat-templates/environments/storage-environment.yaml

# no ceph customization
openstack overcloud deploy -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml -e /home/stack/network-environment.yaml --control-flavor control --compute-flavor compute --ceph-storage-flavor ceph --ntp-server 10.16.255.2 --control-scale 3 --compute-scale 4 --ceph-storage-scale 4 --block-storage-scale 0 --swift-storage-scale 0 -t 90 --templates -e /usr/share/openstack-tripleo-heat-templates/environments/storage-environment.yaml
