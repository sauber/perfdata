#!/bin/sh

# Collect various performance data and insert in rrd files

for h in `/home/sauber/projects/perfdata/temperature.sh` ; do
  #echo == $h =
  l=`echo $h | cut -d : -f 1`
  v=`echo $h | cut -d : -f 2`
  if [ "$v" -gt 0 ] ; then
    if [ "$v" -lt 100 ] ; then
      /home/sauber/projects/perfdata/rrdinsert.pl /data/projects/perfdata $l $v
    fi
  fi
done

