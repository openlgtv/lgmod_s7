#!/bin/sh

USER=$1

TARGET__BD=`hostname`
LSERVER_IP=`cat /proc/cmdline | awk 'BEGIN { RS="[ :]"; FS="="; } /ip=/ { print $2 } END {}'`
TSERVER_IP=`cat /proc/cmdline | awk 'BEGIN { RS="[ ]"; FS=":"; } /ip=/ { print $2 } END {}'`
TARGET_IP=`cat /proc/cmdline | awk 'BEGIN { RS="[ ]"; FS=":"; } /ip=/ { print $3 } END {}'`
GATEWAY_IP=`cat /proc/cmdline | awk 'BEGIN { RS="[ ]"; FS=":"; } /ip=/ { print $4 } END {}'`
NETMASK=`cat /proc/cmdline | awk 'BEGIN { RS="[ ]"; FS=":"; } /ip=/ { print $5 } END {}'`

if [ -z $USER ]; then
	echo Usage: $0 id
	exit 1
fi

# Set IP addresses
ifconfig lo 127.0.0.1 netmask 255.0.0.0 up
ifconfig eth0 $TARGET_IP netmask $NETMASK up

# Set default gw
route add default gw $GATEWAY_IP

mount -t nfs $LSERVER_IP:/share/global_platform/$TARGET__BD/$USER /home -o nolock,rsize=32768,wsize=32768,tcp

if [ $? == 0 ]; then
	cd /home
	echo -ne "nfs mount done!!\n"
	exit 0
fi
