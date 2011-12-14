#!/bin/sh
# Source code released under GPL License
# Extroot script for Saturn6/Saturn7 by mmm4m5m

EXTROOT=lgmod_S7_extroot.tar.gz; [ -n "$1" ] && EXTROOT="$1"
EXTLINK=/mnt/lg/user/extroot; EXTCONF=/mnt/lg/user/lgmod/extroot
EXTMNT=/tmp/lgmod/extroot; EXTDEST=$EXTMNT/extroot; EXTDEV=''; EXTYPE=''; ID=''

EXIT() { sync; [ -n "$2" ] && echo "Error($1): $2"; exit "$1"; }
ULOC() { local D=/usr/local; grep " $D " /proc/mounts | grep -q '^/dev/sd' || return 0
	killall stagecraft && sleep 1; umount $D; }
MLOC() { local D=/usr/local; mount -o bind $EXTDEST$D $D && killall stagecraft; }

echo "NOTE: stagecraft will be auto-stopped (and auto-started)"
echo "	(umount /usr/local and update requires stopping DFB programs)"

EXTROOT="`readlink -f "$EXTROOT"`"
[ -f "$EXTROOT" ] || echo "Warning: extroot archive not found"

if [ -f $EXTCONF ]; then
	ID=`cat $EXTCONF`; EXTYPE="${ID%%:*}"; EXTDEV="${ID#*:}"; EXTDEV="${EXTDEV%%:*}"
	echo "Info: Current config: $ID"
fi

if [ -h $EXTLINK ]; then
	extdest=`readlink -f $EXTLINK`
	[ "$extdest" = $EXTDEST ] || echo "Note: extroot sym.link: $extdest"
else [ -e $EXTLINK ] && EXIT 2 "extroot is not a sym.link: $EXTLINK"; fi


. /etc/init.d/rcS-funcs; # print_devices, load_modules, device_by_id

# list devices and select
EXTDEVS=`print_devices` || EXIT 3 "Can not find USB flash drive(s): /sys/block/sd*"

echo; echo 'Info: Mounted USB drives and partitions:'
cat /proc/mounts | grep '^/dev/sd' &&
	echo 'NOTE: Maybe, you do not want to format FAT/NTFS partitions used by TV'

echo; echo 'Select: Attached USB flash drives:'
i=0
for id in $EXTDEVS; do
	dev=${id%%:*}; id="${id#sd?}"; i=$(( i+1 ))
	[ "${ID#*:}" != "$id" ] && echo " $i: /dev/$dev: $id" ||
		echo "*$i: /dev/$dev (config): $id"
done
[ -n "$ID" ] && echo 'Press <enter> to continue - no changes'
SEL=''; read -p 'Select: extroot drive ("S" to stop)? ' SEL || EXIT 4; [ "$SEL" = S ] && EXIT 1
if [ -n "$SEL" ]; then
	SEL="`echo "$EXTDEVS" | head -n$SEL | tail -n1 | sed -e 's/^sd.//'`"
	echo; echo 'Select: File system type. Press "S" to stop'
	[ -n "$ID" ] && echo 'Press <enter> to continue - no changes'
	typ=''; read -p 'Select: "ext2" or "ext3"? ' typ || EXIT 5; [ "$typ" = S ] && EXIT 1
	SEL="$typ:$SEL"
else SEL="$ID"; fi
echo "Info: selected device: $SEL"

[ -z "$SEL" ] && EXIT 6 'Invalid input'
SELTYP="${SEL%%:*}"; SELDEV="${SEL#*:}"; SELDEV="${SELDEV%%:*}"
[ "$SELTYP" = ext2 ] || [ "$SELTYP" = ext3 ] || EXIT 7 'Invalid input'


# prepare mount point and modules
[ -d $EXTMNT ] || mkdir -p $EXTMNT || EXIT 11 "mkdir: $EXTMNT"

ULOC || EXIT 12 "umount $D"

D=$(stat -c%D $EXTMNT ${EXTMNT%/*}); n=$'\n'
[ "${D%%$n*}" = "${D#*$n}" ] || umount $EXTMNT || EXIT 13 "umount $EXTMNT"

load_modules "modprobe" "$SELTYP" || EXIT 14 "modprobe $SELTYP"


# verify: find device, format and mount
dev=`device_by_id "$SEL" "$SELDEV" "$SELTYP"`
if [ -n "$dev" ]; then
	dev="/dev/$dev$SELDEV"
	echo; echo "Select: Format partition $dev as $SELTYP"
	echo 'Press <enter> to continue - no format. Press "S" to stop'
	NEW=''; read -p 'Select: format - "YES"? ' NEW || EXIT 15; [ "$NEW" = S ] && EXIT 1
	if [ "$NEW" = YES ]; then
		grep "^$dev " /proc/mounts && { umount "$dev" || EXIT 16 "umount $dev"; }
		typ=''; [ $SELTYP = ext3 ] && typ='-j'
		mke2fs -v -L EXTROOT $typ "$dev" || EXIT 17 "mke2fs $typ $dev"
	fi
else EXIT 18 "Device not found: $SEL"; fi

mount -o noatime -t "$SELTYP" "$dev" $EXTMNT || EXIT 18 "mount -t $SELTYP $dev"


# delete old, extract new extroot
echo 3 > /proc/sys/vm/drop_caches

if [ -d $EXTDEST ]; then
	echo; echo "Select: Delete directory $dev/${EXTDEST##*/}"
	echo 'Press <enter> to continue - no delete. Press "S" to stop'
	typ=''; read -p 'Select: delete - "YES"? ' typ || EXIT 21; [ "$typ" = S ] && EXIT 1
	[ "$typ" != YES ] || rm -rf $EXTDEST || EXIT 22 "rm $EXTDEST"
fi

if [ -f "$EXTROOT" ]; then
	echo; echo "Info: Extract $EXTROOT to $dev/${EXTDEST##*/} (2 mins)"
	typ=''
	if [ -d $EXTDEST ]; then
		echo 'Press <enter> to continue and extract. Press "S" to stop'
		read -p 'Select: "NO"? ' typ || EXIT 23; [ "$typ" = S ] && EXIT 1
	else
		mkdir -p $EXTDEST || EXIT 24 "mkdir: $EXTDEST"
	fi
	if [ "$typ" != NO ]; then
		(cd $EXTDEST && tar xzf "$EXTROOT") || EXIT 25 "tar xzvf $EXTROOT"
	fi
fi


# update config file and extroot sym.link
echo

if [ ! -f /usr/bin/readlink ] || [ "`readlink -f $EXTLINK`" != $EXTDEST ]; then
	rm -rf $EXTLINK && ln -s $EXTDEST $EXTLINK &&
		echo "Info: ln -s $EXTDEST $EXTLINK" ||
		EXIT 31 "rm & ln: $EXTLINK ($EXTDEST)"
fi
 
if [ "$ID" != "$SEL" ]; then
	mkdir -p ${EXTCONF%/*} && echo -n "$SEL" > $EXTCONF && sync &&
		echo "DONE: Config file updated: $EXTCONF" ||
		EXIT 32 "Save failed $EXTCONF"
else echo "DONE: Config file not changed: $EXTCONF"; fi


# LG DirectFB to extroot/usr/local
if [ -d /mnt/lg/lginit ]; then # not S6 = S7
	D=/usr/local; d=$EXTDEST; F=$D/etc/directfbrc
	echo; echo "Select: Copy $D to $dev/${EXTDEST##*/} (DirectFB)"
	echo 'Press <enter> to continue and copy. Press "S" to stop'
	typ=''; read -p 'Select: "NO"? ' typ || EXIT 41; [ "$typ" = S ] && EXIT 1
	if [ "$typ" != NO ]; then
		for i in `find $D \! -type d`; do
			[ $i = $F ] && continue
			[ -e $d$i ] && mv $d$i $d$i~; mkdir -p $d${i%/*}
			cp -a $i $d$i && echo "cp -a $d$i" || EXIT 42 "cp -a $d$i"
		done

		echo; echo "Select: Modify $F and copy to $dev/${EXTDEST##*/} (DirectFB)"
		echo 'Press <enter> to continue and copy. Press "S" to stop'
		typ=''; read -p 'Select: "NO"? ' typ || EXIT 43; [ "$typ" = S ] && EXIT 1
		if [ "$typ" != NO ]; then
			i=$F; [ -e $d$i ] && mv $d$i $d$i~; mkdir -p $d${i%/*}
			sed -i -e 's/no-cursor/cursor-updates\nno-linux-input-grab/' $i &&
				cp -a $i $d$i && echo "cp -a $d$i" || EXIT 44 "sed & cp: $d$i"
		fi
	fi
	MLOC || EXIT 45 "mount $D"
fi


sync
