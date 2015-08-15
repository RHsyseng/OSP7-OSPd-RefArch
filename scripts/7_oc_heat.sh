#!/bin/bash

# run this script on the overcloud
set -x

# do not run as root
if [ `id -ng` == root ]
then 
	echo -e "ERROR: running script as root"
	exit 113
fi

# set environment
source ~/overcloudrc
env | grep OS_

# create ext-net
neutron net-create ext-net -- --router:external=True --shared=True
neutron subnet-create --name ext-net --allocation-pool=start=10.19.137.137,end=10.19.137.150 --gateway_ip=10.19.143.254 ext-net 10.19.136.0/21
export ext_net_id=$(neutron net-show ext-net | awk ' / id/ { print $4 } ')

# copy HOT
cp -b /pub/projects/rhos/kilo/scripts/jliberma/new/templates/simple.yaml ~/templates/simple.yaml
cp -b /pub/projects/rhos/kilo/scripts/jliberma/new/templates/eapws.yaml ~/templates/eapws.yaml

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
openstack image list

# create a keypair
openstack keypair create demokp > ~/demokp.pem
chmod 600 ~/demokp.pem
openstack keypair list

heat -v template-validate --template-file templates/simple.yaml
#heat -v stack-create --template-file templates/simple.yaml simple  --parameters="public_net_id=$ext_net_id"
heat -v stack-create --template-file templates/eapws.yaml eap  --parameters="public_net_id=$ext_net_id"
