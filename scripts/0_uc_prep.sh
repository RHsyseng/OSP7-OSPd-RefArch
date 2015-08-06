#!/bin/bash -x
# install OSP via TripleO
set -x

# configure hosts
cat > /etc/hosts << EOF
172.16.2.100 	rhos0.osplocal
10.19.137.100   rhos0.cloud.lab.eng.bos.redhat.com rhos0
172.31.137.100  rhos0-stor
127.0.0.1   	localhost localhost.localdomain localhost4 localhost4.localdomain4
172.16.2.101 	rhos1.osplocal
10.19.137.101   rhos1
172.31.137.101  rhos1-stor
172.16.2.102 	rhos2.osplocal
10.19.137.102   rhos2
172.31.137.102  rhos2-stor
172.16.2.103 	rhos3.osplocal
10.19.137.103   rhos3
172.31.137.103  rhos3-stor
172.16.2.104 	rhos4.osplocal
10.19.137.104   rhos4
172.31.137.104  rhos4-stor
172.16.2.105 	rhos5.osplocal
10.19.137.105   rhos5
172.31.137.105  rhos5-stor
172.16.2.106 	rhos6.osplocal
10.19.137.106   rhos6
172.31.137.106  rhos6-stor
172.16.2.107 	rhos7.osplocal
10.19.137.107   rhos7
172.31.137.107  rhos7-stor
172.16.2.108 	rhos8.osplocal
10.19.137.108   rhos8
172.31.137.108  rhos8-stor
172.16.2.109 	rhos9.osplocal
10.19.137.109   rhos9
172.31.137.109  rhos9-stor
172.16.2.110 	rhosa.osplocal
10.19.137.110   rhosa
172.31.137.110  rhosa-stor
172.16.2.111 	rhosb.osplocal
10.19.137.111   rhosb
172.31.137.111  rhosb-stor
10.19.143.248   refarch.cloud.lab.eng.bos.redhat.com
10.19.143.247   ra-ns1.cloud.lab.eng.bos.redhat.com
EOF

# configure ssh
echo "UserKnownHostsFile /dev/null" > /root/.ssh/config
echo "StrictHostKeyChecking no" >> /root/.ssh/config
echo "LogLevel quiet" >> /root/.ssh/config
restorecon -Rv /root/.ssh

# copy ssh keys
rm -f ~/.ssh/id_rsa*
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# install racadm
#wget -q -O - http://linux.dell.com/repo/hardware/dsu/bootstrap.cgi | bash
#yum -y install dell-system-update # for hardware only
#yum -y install srvadmin-all
#yum -y install openssl-devel
#export PATH=$PATH:/opt/dell/srvadmin/bin:/opt/dell/srvadmin/sbin

# create stack user
useradd stack
echo 'stack:password' | chpasswd 
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack
id stack

# set hostname
hostnamectl set-hostname rhos0.osplocal
hostnamectl set-hostname --transient rhos0.osplocal
export HOSTNAME=rhos0.osplocal
hostname
