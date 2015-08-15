#!/bin/bash

function clean_disks() {

  # ceph-disk zap?
  # ceph-disk prepare?
  # http://ceph.com/docs/master/man/8/ceph-disk/#zap
  systemctl stop ceph.service
  for i in sd{b..m}; do parted -s /dev/$i print; done
  for i in sd{b..m}; do parted -s /dev/$i rm 2; done
  for i in sd{b..m}; do parted -s /dev/$i rm 1; done
  for i in sd{b..m}; do dd if=/dev/zero of=/dev/$i bs=1M count=4; done
  for i in sd{b..m}; do parted -s /dev/$i mklabel gpt; done
  shutdown -r now

}

function bench_osds() {
  ceph osd tree
  ceph osd pool create scbench 100 100
  echo 3 > /proc/sys/vm/drop_caches 
  free -g
<<<<<<< HEAD
  rados bench -p scbench 30 write --no-cleanup
  rados bench -p scbench 30 seq
  rados bench -p scbench 30 rand
=======
  rados bench -t 16 -b 4 -p scbench 30 write --no-cleanup
  rados bench -t 16 -b 4 -p scbench 30 seq
  rados bench -t 16 -b 4 -p scbench 30 rand
>>>>>>> 61b6826a78e5a2d2b94557bb788542803e3a9a26
  rados -p scbench cleanup
  # use -b to change size
  # use -t to change concurrency
  # how to run from multiple clients simultaneously?
  # run against different pools from multiple clients

}

function pool_cmd() {
  ceph osd lspools
  for i in images rbd vms volumes; do ceph osd pool get $i pgp_num; done
  for i in images rbd vms volumes; do ceph osd pool get $i pg_num; done
  for i in images rbd vms volumes; do ceph osd pool get $i size; done
  rados df
<<<<<<< HEAD
  for i in images rbd vms volumes scbench
  do
    ceph osd pool set $i pg_num 128
    ceph osd pool set $i pgp_num 128
=======
  for i in images rbd vms volumes
  do
    ceph osd pool set $i pg_num 4096
    ceph osd pool set $i pgp_num 4096
>>>>>>> 61b6826a78e5a2d2b94557bb788542803e3a9a26
  done
  ceph pg stat

}


