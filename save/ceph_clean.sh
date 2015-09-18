#!/bin/bash -v
source ~/stackrc
env | grep OS_
SSH_CMD="ssh -l heat-admin"

# for all ceph storage servers 
for i in $(nova list | awk ' /ceph/ { print $12 } ' | cut -f2 -d=)
do
        echo $i
	echo -e "$SSH_CMD $i 'sudo systemctl stop ceph.service'"
	$SSH_CMD $i 'sudo systemctl stop ceph.service'
	echo -e "$SSH_CMD $i 'for j in $(mount | awk \" /ceph/ { print $3 } \"); do sudo umount $j; done'"
	$SSH_CMD $i 'for j in $(mount | awk " /ceph/ { print $3 } "); do sudo umount $j; done'
	echo -e "$SSH_CMD $i 'for j in $(mount | awk " /ceph/ { print $3 } "); do sudo umount $j; done'"
	$SSH_CMD $i 'for j in sd{b..m}; do sudo parted --script /dev/$j rm 1; sudo parted -a optimal --script /dev/$j mktable gpt; done'
	echo -e "$SSH_CMD $i 'sudo sync; sudo sh -c \"echo 3 > /proc/sys/vm/drop_caches\"'"
	$SSH_CMD $i 'sudo sync; sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"'
done
