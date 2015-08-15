#!/bin/bash
set -x

source /home/stack/demorc

# delete volumes
for i in $(cinder list | grep in-use); do nova volume-detach $(cinder list | awk ' /in-use/ { print $14" "$2 } '); done
for i in $(cinder list| awk '/test/ { print $2 } '); do cinder delete $i; done

# delete instances
nova keypair-delete demokp
i=1
while [ $i -le 4 ]
do
	nova delete inst$i
	((i++))
done

source /root/overcloudrc

# delete Glance images
for i in $(glance image-list| awk '/qcow2/ { print $2 } '); do glance image-delete $i; done

# delete floating IP
for i in $(neutron floatingip-list| awk '/10.19/ { print $2 } '); do neutron floatingip-delete $i; done

# delete networks
neutron router-interface-delete default-router private
for i in $(neutron port-list| awk '/172/ { print $2 } '); do neutron port-delete $i; done
neutron router-delete route1
neutron subnet-delete demo_subnet
neutron subnet-delete ext-net
neutron net-delete demo_net
neutron net-delete ext-net

# delete tenant
keystone user-delete demo
keystone tenant-delete demo-tenant
