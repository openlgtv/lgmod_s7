#!/bin/sh
msg='openrelease: key: dfbterm'
echo "$msg"; echo "$msg" > /dev/kmsg
D=links

# PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
which $D || {
	msg="$msg - $D not found (extroot?)"
	echo "$msg"; echo "$msg" > /dev/kmsg; exit 2; }

# dfbscreen after kill to clean screen (better way?)
if ! pgrep $D; then $D -g google.com &
else killall $D; sleep 0.1; dfbscreen &
fi
