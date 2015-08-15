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
<<<<<<< HEAD
#tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/08.07-1/deploy-ramdisk-ironic.tar  
#tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/08.07-1/discovery-ramdisk.tar
#tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/08.07-1/overcloud-full.tar
tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/07.30-1/deploy-ramdisk-ironic.tar  
tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/07.30-1/discovery-ramdisk.tar
tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/07.30-1/overcloud-full.tar
=======
tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/08.07-1/deploy-ramdisk-ironic.tar  
tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/08.07-1/discovery-ramdisk.tar
tar xvf /pub/projects/rhos/kilo/scripts/jliberma/new/images/08.07-1/overcloud-full.tar
>>>>>>> 61b6826a78e5a2d2b94557bb788542803e3a9a26

openstack overcloud image upload
openstack image list
