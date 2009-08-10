#!/bin/sh

# Collect various performance data and insert in rrd files

# Temperature data
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

# 5 min. load average
# uptime
# 4:09PM  up 2 days,  3:20, 1 user, load averages: 0.04, 0.08, 0.04
v=`uptime | cut -d , -f 5`
l=load05
/home/sauber/projects/perfdata/rrdinsert.pl /data/projects/perfdata $l $v

