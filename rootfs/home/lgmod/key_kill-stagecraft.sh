#!/bin/sh
msg='key: kill stagecraft'; echo "$msg" > /dev/kmsg; echo "$msg"
killall stagecraft
