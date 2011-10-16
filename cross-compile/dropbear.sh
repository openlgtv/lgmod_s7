#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

PLATFORM=S7; #PLATFORM=''
[ "$1" = S6 ] && { shift; PLATFORM=S6; }
[ "$1" = S7 ] && { shift; PLATFORM=S7; }
[ -z "$PLATFORM" ] && { echo "ERROR: $1=<S6|S7>"; exit 1; }
SUFFIX="-$PLATFORM"
[ "$PLATFORM" = S7 ] && SUFFIX=''; # TODO rootfs-S7

cd "${0%/*}"; CONF_DIR=$(pwd)
d="../rootfs$SUFFIX"; cd "$d" || { echo "ERROR: $d not found."; exit 1; }; INST_DIR=$(pwd)
cd ../../..
if [ "$PLATFORM" = S7 ]; then CC_DIR="$(pwd)/Saturn7/cross-compiler"; CC_PREF=mipsel-linux
else CC_DIR="$(pwd)/cross-compiler-mipsel"; CC_PREF=mipsel; fi
d=sources; mkdir -p $d; cd $d; SRC_dir=dropbear-0.53.1; SRC_DIR="$(pwd)/$SRC_dir"

# download, extract
dir=$SRC_dir
if [ ! -d "$dir" ]; then
	tar=$dir.tar.bz2
	read -n1 -p "Press Y to download and extract $tar ... " r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://matt.ucc.asn.au/dropbear/releases/$tar" || exit 3; }
	tar -xjf "$tar"
	exit
fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 11; }
[ -d "$SRC_DIR" ] || { echo "ERROR: $SRC_DIR not found."; exit 12; }
export PATH="$CC_BIN:$PATH"
cd "$SRC_DIR"

# config, build
[ "$1" = bash ] && { bash; exit; }
[ "$1" = noclean ] && shift || { make clean
	# S7 binary files size:
	#	229380 usr/sbin/dropbear
	#	37800  usr/sbin/scp
	#	221160 usr/bin/dbclient
	#	90084  usr/bin/dropbearkey
	#	85152  usr/lib/dropbear/dropbearconvert
	# S7 binary files size: --disable-zlib --disable-pam --disable-utmpx --disable-wtmpx --disable-openpty
	#	total -24 bytes
	# S7 binary files size: --disable-zlib --disable-pam --disable-utmpx --disable-wtmpx --disable-pututline --disable-pututxline --disable-utmp --disable-wtmp --disable-lastlog --disable-syslog --disable-shadow --disable-openpty --disable-loginfunc --disable-largefile
	#	225052 usr/sbin/dropbear
	#	37592  usr/sbin/scp
	#	216792 usr/bin/dbclient
	#	85116  usr/lib/dropbear/dropbearconvert
	if [ "$PLATFORM" = S7 ]; then
	     ./configure --host=$CC_PREF
	else ./configure --host=$CC_PREF; fi; }
[ "$1" = nomake ] && shift || {
	if [ "$PLATFORM" = S7 ]; then make PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp"; # STATIC=1
	else make PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" STATIC=1; fi; }

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press Y to install in $INST_DIR ... " r; echo; [ "$r" = Y ] || exit
d="$INST_DIR/usr/sbin/"
for i in dropbear scp; do
	f="$d$i"; cp -ax $i "$f"; "$CC_BIN/$CC_PREF-strip" --strip-unneeded "$f"; ls -l "$f"; done
d="$INST_DIR/usr/bin/"
for i in dbclient dropbearkey; do
	f="$d$i"; cp -ax $i "$f"; "$CC_BIN/$CC_PREF-strip" --strip-unneeded "$f"; ls -l "$f"; done
d="$INST_DIR/usr/lib/dropbear/"
for i in dropbearconvert; do
	f="$d$i"; cp -ax $i "$f"; "$CC_BIN/$CC_PREF-strip" --strip-unneeded "$f"; ls -l "$f"; done
