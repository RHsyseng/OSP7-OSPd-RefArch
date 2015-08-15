#!/bin/bash

for i in 30 60 90
do
        rados -p scbench cleanup
        echo 3 > /proc/sys/vm/drop_caches
        echo -e "rados bench -p scbench $i write --no-cleanup" 
        rados bench -p scbench $i write --no-cleanup | grep -A 5 "Total time" | grep -v "^$"
        echo 3 > /proc/sys/vm/drop_caches
        echo -e "rados bench -p scbench $i seq"
        rados bench -p scbench $i seq | grep -A 3 "Total time"
        echo 3 > /proc/sys/vm/drop_caches
        echo -e "rados bench -p scbench $i rand"
        rados bench -p scbench $i rand | grep -A 3 "Total time"
        rados -p scbench cleanup
done

