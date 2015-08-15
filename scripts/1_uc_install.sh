#!/bin/bash

# check for running as root
if [ `id -ng` == root ]
then 
	echo -e "ERROR: running script as root"
	exit 113
fi

# update packages
sudo yum update -y
sudo yum install -y yum-utils

# install openstack
sudo yum localinstall -y http://rhos-release.virt.bos.redhat.com/repos/rhos-release/rhos-release-latest.noarch.rpm
#sudo rhos-release 7-director
sudo rhos-release -p GA 7-director
sudo rhos-release -L
sudo yum install -y python-rdomanager-oscplugin
sudo rpm -q python-rdomanager-oscplugin

# enable the rhelosp opt repo
sudo yum-config-manager --enable rhelosp-rhel-7-server-opt
sudo yum repolist
sudo yum update -y

# create the answer file
#cp /usr/share/instack-undercloud/undercloud.conf.sample ~/undercloud.conf
cat > ~/undercloud.conf << EOF
[DEFAULT]

image_path = .
local_ip = 192.0.2.1/24
#undercloud_public_vip = 192.0.2.2
#undercloud_admin_vip = 192.0.2.3
#undercloud_service_certificate =
local_interface = eno4
masquerade_network = 192.0.2.0/24
dhcp_start = 192.0.2.5
dhcp_end = 192.0.2.24
network_cidr = 192.0.2.0/24
network_gateway = 192.0.2.1
discovery_interface = br-ctlplane
discovery_iprange = 192.0.2.100,192.0.2.120
discovery_runbench = false
undercloud_debug = true

[auth]

undercloud_db_password =
undercloud_admin_token =
undercloud_admin_password =
undercloud_glance_password =
undercloud_heat_encryption_key =
undercloud_heat_password =
undercloud_neutron_password =
undercloud_nova_password =
undercloud_ironic_password =
undercloud_tuskar_password =
undercloud_ceilometer_password =
undercloud_ceilometer_metering_secret =
undercloud_ceilometer_snmpd_user =
undercloud_ceilometer_snmpd_password =
undercloud_swift_password =
undercloud_rabbit_cookie =
undercloud_rabbit_password =
undercloud_rabbit_username =
undercloud_heat_stack_domain_admin_password =
undercloud_swift_hash_suffix =
EOF

# install the undercloud 
# TODO: replace this with a tee command
openstack undercloud install | tee uc.out 2>&1

source ~/stackrc
openstack-service status

# customize undercloud deployment
# increase max database connections
#https://bugzilla.redhat.com/show_bug.cgi?id=1251566
sudo sed -i 's/max_connections =.*$/max_connections = 4096/' /etc/my.cnf.d/server.cnf 
sudo grep max_connections /etc/my.cnf.d/server.cnf 
sudo mysql -e "SET GLOBAL max_connections = 4096"
sudo mysql -e "SHOW GLOBAL VARIABLES LIKE 'max_connections'"

# to check number of threads connecting:
#mysql -e "SHOW STATUS WHERE variable_name = 'Threads_connected'"

# increase neutron port quotas
# https://bugzilla.redhat.com/show_bug.cgi?id=1251571
<<<<<<< HEAD
neutron quota-update --port -1
#neutron quota-update --port 100
=======
neutron quota-update --port 100
>>>>>>> 61b6826a78e5a2d2b94557bb788542803e3a9a26
neutron quota-show

# increase ironic timeouts
#https://bugzilla.redhat.com/show_bug.cgi?id=1251117
sudo openstack-config --set /etc/nova/nova.conf DEFAULT rpc_response_timeout 600
sudo openstack-config --set /etc/ironic/ironic.conf DEFAULT rpc_response_timeout 600
sudo openstack-service restart nova
sudo openstack-service restart ironic
sudo openstack-service status | grep -e 'ironic|nova'
sudo openstack-config --get /etc/nova/nova.conf DEFAULT rpc_response_timeout
sudo openstack-config --get /etc/ironic/ironic.conf DEFAULT rpc_response_timeout

