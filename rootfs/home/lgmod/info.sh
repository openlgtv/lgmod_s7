#!/bin/sh
# Source code released under GPL License
# Info script for Saturn6/Saturn7/BCM by mmm4m5m,xeros

# modify with care - script is used by install.sh

VER=10011; # version of info file (file syntax)
wget=/mnt/lg/user/extroot/usr/bin/wget
MODEL=`echo /mnt/lg/user/model.*`
[ -f "$MODEL" ] && MODEL="${MODEL#*model.}" || MODEL=''

part="$1"
if   [ "$1" = root ];   then shift; # part 1 - before chroot
elif [ "$1" = chroot ]; then shift; # part 2 - in chroot - part 1 (from $infotemp) will be included
elif [ "$1" = paste ];  then shift; # all info and upload to pastebin.com (pastebin.ca)
else part=''; fi; # all info

infotemp=/tmp/info-file
infofile="$1"; [ -z "$1" ] && infofile="$infotemp"
wgetfile="$infofile.wget"; # encoded/prepared for wget --post-data



save=''; err=0

DROP() {
	if [ ! -d /mnt/user ]; then # S6/S7 = not BCM
		echo 3 > /proc/sys/vm/drop_caches
	fi
}

INFO() { { echo; echo; echo "$@"; } >> "$infofile"; save="$@"; }

CMD() {
	local e="$1"; shift; INFO '$#' "$@"
	$@ >> "$infofile" 2>&1 || ERR "$e"
}

ERR() {
	local e=$? m="$2"; [ $1 -gt $err ] && err=$1
	[ -n "$save" ] && echo "$save" && save=''
	[ -z "$m" ] && m="Error: exitcode=$e"
	echo "$m" >> "$infofile"; echo "$m"
}



INFO_ROOT() {
	INFO '$# df -h'; tmp=`df -h` 2>> "$infofile" || ERR 12; echo "$tmp" | grep -v '^/dev/sd' >> "$infofile"
	CMD 12 busybox
	CMD 10 help
	INFO '$# dmesg'; dmesg | grep ACTIVE >> "$infofile"; dmesg >> "$infofile" 2>&1 || ERR 15

	for i in /var/www/cgi-bin/version /proc/version_for_lg /etc/version_for_lg /mnt/lg/model/* \
		/mnt/lg/user/lgmod/boot /mnt/lg/user/lgmod/init/*; do
		[ -f "$i" ] || continue
		echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' >> "$infofile"
		CMD 16 cat $i
	done
	echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' >> "$infofile"

	INFO '#$ list some files'
	CMD 0 ls -lR /etc /mnt/lg/lginit /mnt/lg/bt /mnt/lg/user /mnt/lg/cmn_data /mnt/lg/model \
			/mnt/lg/lgapp /mnt/lg/res/lgres /mnt/lg/res/lgfont /usr/local \
			/mnt/addon/bin /mnt/addon/lib /mnt/addon/stagecraft
	CMD 0 ls -l /mnt/addon /mnt/lg/ciplus /mnt/lg/res/estreamer
}

INFO_CHROOT_A() {
	busybox=''; #/bin/busybox; # old
	CMD 11 cat /proc/mtd

	f=`grep -m1 mtdinfo /proc/mtd | cut -d: -f1`; c=`cat /proc/mtd | wc -l`
	INFO '#$' "dump mtdinfo: /dev/$f"
	if [ -d /mnt/user ]; then # not S6/S7 = BCM
		[ "$f" = mtd1 ] || ERR 17 "Error: mtdinfo in $f: Not BCM TV?"
	else
		[ "$f" = mtd2 ] || ERR 17 "Error: mtdinfo in $f: Not S7 TV?"
		[ $c = 26 ] || ERR 17 "Error: $c partitions: Not S7 TV?"
	fi
	if [ -e "/dev/$f" ]; then
		mtdinfo=`$busybox hexdump /dev/$f -vs240 -e'32 "%_p" " %08x ""%08x " 32 "%_p" " %8d"" %8x " /1 "Uu:%x" /1 " %x " /1 "CIMF:%x" /1 " %x" "\n"' | head -n$c`
		{ echo "0:$mtdinfo" | head -n1; echo "$mtdinfo" | tail -n+2 | grep '' -n; } >> "$infofile" || ERR 13
	fi

	DROP; INFO '#$ dump the magic: /dev/mtd#'
	for i in `cat /proc/mtd | grep '^mtd' | sed -e 's/:.*//' -e 's/^/\/dev\//'`; do
		{ echo -n "$i: "; $busybox hexdump $i -vn32 -e'32 "%4_c" "\n"'; } >> "$infofile" 2>&1 || ERR 13; done

	INFO "INFO: `date`"
	CMD 12 free
	CMD 11 cat /proc/cpuinfo
	CMD 12 lsmod
	CMD 11 cat /proc/version
	INFO '$# cat /proc/cmdline'; tmp=`cat /proc/cmdline` 2>> "$infofile" || ERR 11; printf '%s\n' $tmp >> "$infofile"
	CMD 12 hostname
	CMD 11 cat /proc/filesystems
	INFO '$# export'; tmp=`export` 2>> "$infofile" || ERR 10; echo "$tmp" | sort >> "$infofile"
	INFO '$# printenv'; tmp=`printenv` 2>> "$infofile" || ERR 12; echo "$tmp" | sort >> "$infofile"
	if [ -h `which ps` ]; then CMD 12 ps w; else CMD 12 ps axl; CMD 12 ps axv; fi
	CMD 11 cat /proc/mounts
	INFO '$# fdisk -l'
	tmp=`fdisk -l $(cat /proc/mtd | tail -n+2 | sed -e 's/:.*//' -e 's/^mtd/\/dev\/mtdblock/')` 2>> "$infofile" || ERR 14
	echo "$tmp" | grep ':' >> "$infofile"
	CMD 11 cat /proc/bus/usb/devices
}

INFO_CHROOT_B() {
	INFO '#$ dump RELEASE version'; f=/mnt/lg/lgapp/bin/RELEASE; [ -f "$f" ] || f=/mnt/lg/lgapp/RELEASE
	if [ -f "$f" ]; then
		info_REL=/scripts/info_RELEASE.sh; bbe=/usr/bin/bbe
		if [ -x "$bbe" -a -x "$info_REL" ]; then
			$info_REL $f >> "$infofile" || { ERR 18; break; }
		else
			s=$(stat -c%s $f); b=$((s/18)); none=1
			for i in 9 8 10; do
				DROP; dd bs=$b skip=$i count=1 if=$f > /tmp/info-dump 2>> "$infofile" || { ERR 18; break; }
				cat /tmp/info-dump | tr [:space:] ' '|tr -c ' [:alnum:][:punct:]' '\n'| \
					grep '....'|grep -v '.\{30\}'|grep -m1 -B1 -A5 swfarm >> "$infofile" && none=0 && break
			done
			[ $none = 1 ] && ERR 18 || none=1
			for i in 15 14 16; do
				DROP; dd bs=$b skip=$i count=1 if=$f > /tmp/info-dump 2>> "$infofile" || { ERR 18; break; }
				cat /tmp/info-dump | tr [:space:] ' '|tr -c ' [:alnum:][:punct:]' '\n'| \
					grep '....'|grep -v '.\{30\}'|grep -m1 -B1 -A10 swfarm >> "$infofile" && none=0 && break
			done
			[ $none = 1 ] && ERR 18 'Error: not found'
		fi
	else ERR 0 'Note: not found'; fi

	INFO "INFO: `date`"
	f=/mnt/lg/lginit/lg-init; [ -f $f ] || f=/mnt/lg/lginit/lginit
	INFO '#$' "strings $f"
	if [ -f "$f" ]; then
		DROP; md5sum $f >> "$infofile" || ERR 18
		w=5;m=3;cat $f |tr [:space:] ' '|tr -c ' [:alnum:][:punct:]' '\n'|sed -e'/[a-zA-Z]\{'$m'\}\|[0-9]\{'$m'\}/!d' \
			-e'/[-_=/\.:0-9a-zA-Z]\{'$w'\}/!d' -e's/  \+/ /g'| head -n70 >> "$infofile" || ERR 18
	else ERR 0 'Note: not found'; fi

	INFO "INFO: `date`"

	f=`grep -m1 boot /proc/mtd | cut -d: -f1`
	INFO '#$' "strings boot: /dev/$f"
	if [ -d /mnt/user ]; then # not S6/S7 = BCM
		[ "$f" = mtd0 ] || ERR 17 "Error: boot in $f: Not BCM TV?"
	else
		[ "$f" = mtd1 ] || ERR 17 "Error: boot in $f: Not S7 TV?"
	fi
	if [ -c "/dev/$f" ]; then
		DROP; s=7;w=5;m=3;cat /dev/$f |tr [:space:] ' '|tr -c ' [:alnum:][:punct:]' '\n'| \
			sed -e'/[a-zA-Z]\{'$m'\}\|[0-9]\{'$m'\}/!d' -e'/[-_=/\.:0-9a-zA-Z]\{'$w'\}/!d' \
			-e's/  \+/ /g' -e'/.\{'$s'\}/!d'| tail -n35 >> "$infofile" || ERR 18
	fi

	F1="$f"; f=`grep -m2 boot /proc/mtd | cut -d: -f1 | tail -n+2`; F2="$f"
	if [ -d /mnt/user ]; then # not S6/S7 = BCM
		INFO '#$' "strings boot backup: /dev/$f"
		[ -z "$f" ] || ERR 17 "Error: boot backup in $f: Not BCM TV?"
	else
		INFO '#$' "strings boot backup: /dev/$f"
		[ "$f" = mtd5 ] || ERR 17 "Error: boot backup in $f: Not S7 TV?"
	fi
	if [ -c "/dev/$f" ]; then
		DROP; s=7;w=5;m=3;cat /dev/$f |tr [:space:] ' '|tr -c ' [:alnum:][:punct:]' '\n'| \
			sed -e'/[a-zA-Z]\{'$m'\}\|[0-9]\{'$m'\}/!d' -e'/[-_=/\.:0-9a-zA-Z]\{'$w'\}/!d' \
			-e's/  \+/ /g' -e'/.\{'$s'\}/!d'| tail -n35 >> "$infofile" || ERR 18
	fi

	if [ -c "/dev/$F1" ] && [ -c "/dev/$F2" ]; then
		DROP; INFO '$#' "diff /dev/$F1 /dev/$F2"
		diff /dev/$F1 /dev/$F2 >> "$infofile" 2>&1 || ERR 0
	fi
}



INFO_CHROOT() {
	INFO_CHROOT_A
	[ -f /tmp/install-info ] && CMD 11 cat "$infotemp"
	INFO_CHROOT_B
}

INFO_ALL() {
	INFO_CHROOT_A
	INFO_ROOT
	INFO_CHROOT_B
}


[ "$part" != root ] && echo "NOTE: Create info file (1 min, $infofile) ..."

echo "$VER $MODEL: $@" > "$infofile" || { echo "Error: Info file failed: $infofile"; exit 19; }
INFO "INFO: `date`"
if   [ "$part" = root ];   then INFO_ROOT
elif [ "$part" = chroot ]; then INFO_CHROOT
else INFO_ALL; fi
INFO "INFO: `date`"; DROP; sync

[ $err = 0 ] || echo "Error($err): Info file failed: $infofile"
[ "$part" != root ] && [ $err = 0 ] && echo "Done: Info file: $infofile"


if [ "$part" = paste ]; then
	[ ! -f $wget ] && echo "NOTE: $wget not found (extroot?)" && exit 1
	name="$MODEL"; [ -z "$name" ] && name=`hostname`; [ -z "$name" ] && name='NA'

	#URL='http://pastebin.ca/quiet-paste.php?api=GO2sUUgKHm5v4WAAXooevnRBoI0bdGhc'; # type=23 - bash (?)
	#echo -n "name=$name&type=&description=/tmp/OpenLGTV-info-file.txt&expiry=1+month&s=Submit+Post&content=" > "$wgetfile" || exit

	URL='http://pastebin.com/api_public.php'; # paste_format=bash (?)
	echo -n "paste_name=$name&paste_format=1&paste_expire_date=1M&paste_private=1&paste_code=" > "$wgetfile" || exit

	cat "$infofile" | sed -e 's|%|%25|g' -e 's|&|%26|g' -e 's|+|%2b|g' -e 's| |+|g' >> "$wgetfile" &&
		echo $wget -O /tmp/info-file.pbin --tries=2 --timeout=30 --post-file="$wgetfile" "$URL" &&
		$wget -O /tmp/info-file.pbin --tries=2 --timeout=30 --post-file="$wgetfile" "$URL" &&
		echo 'NOTE: To share your info file, please find the link below:'
	cat /tmp/info-file.pbin; echo
fi
