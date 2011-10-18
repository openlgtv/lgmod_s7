#!/bin/sh

TSERVER_IP=`cat /proc/cmdline | awk 'BEGIN { RS="[ ]"; FS=":"; } /ip=/ { print $2 } END {}'`

dnfiles="ToTFTP.tgz"

BEQUIET=`cat /proc/cmdline | grep quiet`
if [ "$BEQUIET" != "" ]; then
    export PRINTLOG=0
else
    export PRINTLOG=1
fi

export LOG_CALLER=YES
export OSAMEM_SIZE=0x200000
export LOAD_SYM=1
export HOOK_SEGV=YES

for obj in $dnfiles; do

	echo -n "Download $obj	... "

	tftp -g -r $obj $TSERVER_IP

	if test $? -ne 0 ; then
		echo "Failed !";
	else
		echo "OK";
	fi
done

echo ""

tar -xvzf $dnfiles >/dev/null; rm -rf $dnfiles

# remount for resource path
mount -n -t ramfs ramfs /mnt/lg/res
res=`ls /lgsw/res`
for res in $res; do
    ln -s -f /lgsw/res/$res /mnt/lg/res/$res
done

echo -ne "Insert Kernel Driver!!\n"
chmod +x insdrv
./insdrv

# check bluetooth inclusion
BT=`cat /proc/devices | grep bt_usb`
if [ "$BT" != "" ]; then
    mount -t tmpfs tmpfs /mnt/lg/bt -o size=10M
fi

chmod +x RELEASE
./RELEASE
