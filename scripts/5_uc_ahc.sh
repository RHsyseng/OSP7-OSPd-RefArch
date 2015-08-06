#!/bin/bash

set -x

if [ `id -ng` == root ]
then 
	echo -e "ERROR: running script as root"
	exit 113
fi

# install ahc-tools
sudo yum install -y ahc-tools

# create the configuration file
sudo cp /etc/ironic-discoverd/discoverd.conf /etc/ahc-tools/ahc-tools.conf 
sudo sed -i 's/\[discoverd/\[ironic/' /etc/ahc-tools/ahc-tools.conf
sudo chmod 0600 /etc/ahc-tools/ahc-tools.conf
sudo cat /etc/ahc-tools/ahc-tools.conf

# state
sudo cat > /etc/ahc-tools/edeploy/state << EOF
[('control', '3'), ('ceph', '4'), ('compute', '*')]
EOF

# control.specs
sudo cat > /etc/ahc-tools/edeploy/control.specs<< EOF
[
 ('disk', '$disk', 'size', 'gt(20)'),
 ('memory', 'total', 'size', 'ge(6400000000)'),
]
EOF

# compute.specs
sudo cat > /etc/ahc-tools/edeploy/compute.specs << EOF
[
 ('disk', '$disk', 'size', 'gt(100)'),
 ('memory', 'total', 'size', 'ge(6400000000)'),
]
EOF

# ceph.cpecs
sudo cat > /etc/ahc-tools/edeploy/ceph.specs << EOF
[
 ('disk', '$disk', 'size', 'gt(500)'),
 ('memory', 'total', 'size', 'ge(3200000000)'),
]
EOF

# create flavors to use advanced matching
openstack flavor create --id auto --ram 4096 --disk 40 --vcpus 1 control
openstack flavor create --id auto --ram 4096 --disk 40 --vcpus 1 compute
openstack flavor create --id auto --ram 4096 --disk 40 --vcpus 1 ceph 

# assign the flavors
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="control" control
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="compute" compute
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="ceph" ceph

# run the ahc matching tool
sudo ahc-match 2 > match.err

# view the results
for i in $(ironic node-list | awk ' /available/ { print $2 } ')
do 
	ironic node-show $i | grep capabilities 
done
