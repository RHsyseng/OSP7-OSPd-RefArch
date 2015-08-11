#!/bin/bash

# make sure not running as root
if [ `id -u` == 0 ]
then
        echo -e "ERROR: running script as root"
        exit 113
fi

source ~/stackrc
cd ~

# extract images
tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/08.07-1/deploy-ramdisk-ironic.tar  
tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/08.07-1/discovery-ramdisk.tar
tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/08.07-1/overcloud-full.tar

openstack overcloud image upload
openstack image list
