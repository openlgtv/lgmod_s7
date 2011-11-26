#!/bin/sh
msg='openrelease: key: kill stagecraft'
echo "$msg"; echo "$msg" > /dev/kmsg
D=stagecraft

killall $D
