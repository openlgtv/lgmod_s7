#!/bin/sh
msg='key: kill stagecraft'
echo "$msg"; echo "$msg" > /dev/kmsg

killall stagecraft
