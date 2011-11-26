#!/bin/sh
msg='key: dfbterm'
echo "$msg"; echo "$msg" > /dev/kmsg

# check with 'stat' and mount-bind once
rdir=/usr/local; dir=/mnt/lg/user/extroot$rdir
D=$(stat -c%D $rdir $rdir/bin); n=$'\n'
[ "${D%%$n*}" = "${D#*$n}" ] && mount -o bind "$dir" "$rdir"

# PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
D=dfbterm; # dfbscreen to clean the screen after kill (better way?)
if ! pgrep $D; then $D &
else killall $D; sleep 0.1; dfbscreen; fi
