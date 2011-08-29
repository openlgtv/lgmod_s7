#!/bin/sh
# Autostart script launched at the end of LGMOD boot
# at that time you have USB and network working normally
# as well as RELEASE running

# Luca's hack to release caches every second (uncomment if you use NFS shares)
#while true ; do echo 3 > /proc/sys/vm/drop_caches ; sleep 10 ; done &
