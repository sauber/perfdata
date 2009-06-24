#!/bin/sh

# Collect temperature for each cpu
for c in 0 1 2 3 ; do
  echo -n "cpu$c "
  sysctl -n dev.cpu.$c.temperature
done

# Collect temporature for each harddisk
for d in 6 8 12 14 ; do
  echo -n "ad$d "
  smartctl -A /dev/ad$d | grep 194 | awk '{print $10}'
done
