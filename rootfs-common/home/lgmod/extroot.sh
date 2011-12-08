#!/bin/sh
# Source code released under GPL License
# Extroot script for Saturn6/Saturn7 by mmm4m5m

EXTROOT=lgmod_S7_extroot.tar.gz; [ -n "$1" ] && EXTROOT="$1"
EXTLINK=/mnt/lg/user/extroot; EXTCONF=/mnt/lg/user/lgmod/extroot
EXTMNT=/tmp/lgmod/extroot; EXTDEST=$EXTMNT/extroot; EXTDEV=''; EXTYPE=''; ID=''

EXIT() { sync; [ -n "$2" ] && echo "Error($1): $2"; exit "$1"; }
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


# list devices and select
EXTDEVS='/sys/block/sd?/sd??'
[ "`echo $EXTDEVS`" = "$EXTDEVS" ] &&
	EXIT 3 "Can not find USB flash drive(s): $EXTDEVS"

EXTDEVS=$(for i in $EXTDEVS; do
	[ -d $i ] || continue; dev=${i##*/}
	id="`cat $i/../device/vendor`"; id="`echo $id`"
	id="$id:`cat $i/../device/../../../../serial`"
	id="$id:`cat $i/../device/../../../../idVendor`"
	id="$id:`cat $i/../device/../../../../idProduct`"
	echo "$dev:$id"; done)

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

D=$(stat -c%D $EXTMNT ${EXTMNT%/*}); n=$'\n'
[ "${D%%$n*}" = "${D#*$n}" ] || umount $EXTMNT || EXIT 12 "umount $EXTMNT"

[ "$SELTYP" = ext3 ] && modprobe jbd
modprobe "$SELTYP" || EXIT 13 "modprobe $SELTYP"


# verify/find device, format and mount
id=''; dev=''; NEW=''
for i in /sys/block/sd?; do
	dev=${i##*/}; [ -d $i ] && [ -d "$i/$dev$SELDEV" ] || continue
	id="`cat $i/device/vendor`"; id="`echo $id`"
	id="$id:`cat $i/device/../../../../serial`"
	id="$id:`cat $i/device/../../../../idVendor`"
	id="$id:`cat $i/device/../../../../idProduct`"
	[ "$SEL" = "$SELTYP:$SELDEV:$id" ] || continue; dev="/dev/$dev$SELDEV"

	echo; echo "Select: Format partition $dev as $SELTYP"
	echo 'Press <enter> to continue - no format. Press "S" to stop'
	NEW=''; read -p 'Select: format - "YES"? ' NEW || EXIT 14; [ "$NEW" = S ] && EXIT 1
	[ -z "$NEW" ] && break; [ "$NEW" = YES ] || break

	grep "^$dev " /proc/mounts &&  { umount "$dev" || EXIT 15 "umount $dev"; }

	typ=''; [ $SELTYP = ext3 ] && typ='-j'
	mke2fs -v -h EXTROOT $typ "$dev" || EXIT 16 "mke2fs $typ $dev"
	break
done
[ "$SEL" != "$SELTYP:$SELDEV:$id" ] && EXIT 17 "Device not found: $SEL"

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

if [ "`readlink -f $EXTLINK`" != $EXTDEST ]; then
	rm -rf $EXTLINK && ln -s $EXTDEST $EXTLINK &&
		echo 'Info: ln -s $EXTDEST $EXTLINK' ||
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
		if grep " $D " /proc/mounts | grep '^/dev/sd'; then
			killall stagecraft && sleep 1 && umount $D || EXIT 42 "umount $D"
		fi

		for i in `find $D \! -type d`; do
			[ $i = $F ] && continue
			[ -e $d$i ] && mv $d$i $d$i~; mkdir -p $d${i%/*}
			cp -a $i $d$i && echo "cp -a $d$i" || EXIT 43 "cp -a $d$i"
		done

		echo; echo "Select: Modify $F and copy to $dev/${EXTDEST##*/} (DirectFB)"
		echo 'Press <enter> to continue and copy. Press "S" to stop'
		typ=''; read -p 'Select: "NO"? ' typ || EXIT 44; [ "$typ" = S ] && EXIT 1
		if [ "$typ" != NO ]; then
			i=$F; [ -e $d$i ] && mv $d$i $d$i~; mkdir -p $d${i%/*}
			sed -i -e 's/no-cursor/cursor-updates\nno-linux-input-grab/' $i &&
				cp -a $i $d$i && echo "cp -a $d$i" || EXIT 45 "sed & cp: $d$i"
		fi

		umount -o bind $d$D $D && killall stagecraft
	fi
fi


sync
