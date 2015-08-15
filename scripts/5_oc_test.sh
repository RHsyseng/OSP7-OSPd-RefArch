#!/bin/bash


# TODO: add a tenant and execute as the tenant user

# run this script on the overcloud
set -x

# set environment
source ~/overcloudrc
env | grep OS_

# create ext-net
neutron net-create ext-net -- --router:external=True --shared=True
neutron subnet-create --name ext-net --allocation-pool=start=10.19.137.137,end=10.19.137.150 --gateway_ip=10.19.143.254 ext-net 10.19.136.0/21

# create a tenant and tenant user
openstack user create --password redhat demo
openstack project create demo-tenant
openstack role add --user demo --project demo-tenant _member_

# create the tenant user keystonerc file
cat > ~/demorc << EOF
export OS_USERNAME=demo
export OS_TENANT_NAME=demo-tenant
export OS_PASSWORD=redhat
export OS_CLOUDNAME=overcloud
export OS_AUTH_URL=${OS_AUTH_URL}
export PS1='[\u@\h \W(demo_member)]\$ '
EOF

# source the keystonerc file
source ~/demorc
env | grep OS_

# import the virtual machine disk image
openstack image create --disk-format qcow2  --container-format bare --file /pub/projects/rhos/icehouse/scripts/jliberma/rhel-guest-image-7.0-20140506.1.x86_64.qcow2 rhel-server7
openstack image create --disk-format qcow2  --container-format bare --file /pub/projects/rhos/common/images/rhel-guest-image-6-6.5-20131115.0-1.qcow2.unlock rhel-server6u
openstack image list

# create a tenant network
neutron net-create demo_net
neutron subnet-create --name demo_subnet demo_net 172.16.5.0/24
demo_net=$(neutron net-list | awk ' /demo/ { print $2 } ')

# create security group rules to allow SSH, ICMP, and HTTP traffic to instances in this security group
default_id=$(openstack security group list| awk ' /default/ { print $2 } ')
openstack security group rule create --proto tcp --dst-port 443 $default_id
openstack security group rule create --proto tcp --dst-port 22 $default_id
openstack security group rule create --proto tcp --dst-port 80 $default_id
openstack security group rule create --proto icmp $default_id
neutron security-group-rule-create --protocol icmp  $default_id
openstack security group rule list $default_id 

# create a keypair
openstack keypair create demokp > ~/demokp.pem
chmod 600 ~/demokp.pem
openstack keypair list

# boot an instance on each compute node
openstack server create --flavor 2 --image rhel-server7 --key-name demokp inst1 --nic net-id=$demo_net
openstack server create --flavor 2 --image rhel-server7 --key-name demokp inst2 --nic net-id=$demo_net
openstack server create --flavor 2 --image rhel-server6u --key-name demokp inst3 --nic net-id=$demo_net
openstack server create --flavor 2 --image rhel-server6u --key-name demokp inst4 --nic net-id=$demo_net
while [[ $(openstack server  list | grep BUILD) ]]
do
	sleep 5
done
openstack server list

# attach a volume
openstack volume create --size 1 test
sleep 10
volid=$(openstack volume list | awk ' /test/ { print $2 } ')
openstack server add volume inst1 $volid 
openstack volume list

# create a router for external access from the demo subnet
neutron router-create route1

# attach the demo subnet to the router
subnet_id=$(neutron subnet-list | awk ' /172.16.5.0/ { print $2 } ')
neutron router-interface-add route1 $subnet_id

# set the router gateway to ext-net
neutron router-gateway-set route1 ext-net

# create a floating IP address
floatip=$(openstack ip floating create ext-net | awk ' / ip/ { print $4 } ')
echo $floatip
openstack ip floating add $floatip inst1
sleep 30

# access inst1 by floating IP
ssh -l cloud-user -i ~/demokp.pem $floatip uptime

# ping instance 2 from instance 1
inst2_ip=$(openstack server show inst2 | awk '/demo_net/ {print $4}' | cut -f2 -d=)
ssh -l cloud-user -i ~/demokp.pem $floatip ping -c 3 $inst2_ip

# subscription manager
#sudo rpm -ivh http://ra-ns1.cloud.lab.eng.bos.redhat.com/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm

