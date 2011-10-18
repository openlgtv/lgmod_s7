#!/bin/sh

USER=$1

TARGET__BD=`hostname`
LSERVER_IP=`cat /proc/cmdline | awk 'BEGIN { RS="[ :]"; FS="="; } /ip=/ { print $2 } END {}'`

if [ -z $USER ]; then
	echo Usage: $0 id
	exit 1
fi

mount -t nfs $LSERVER_IP:/share/global_platform/$TARGET__BD/$USER /home -o nolock,rsize=32768,wsize=32768,tcp

if [ $? == 0 ]; then
	cd /home
	echo -ne "nfs mount done!!\n"
	exit 0
fi
