#!/bin/bash

PLATFORM=S7; #PLATFORM=''
[ "$1" = S6 ] && { shift; PLATFORM=S6; }
[ "$1" = S7 ] && { shift; PLATFORM=S7; }
[ -z "$PLATFORM" ] && { echo "ERROR: $1=<S6|S7>"; exit 1; }
SUFFIX="-$PLATFORM"
[ "$PLATFORM" = S7 ] && SUFFIX=''; # TODO rootfs-S7

cd "${0%/*}"; CONF_DIR=$(pwd)
d="../rootfs$SUFFIX"; cd "$d" || { echo "ERROR: $d not found."; exit 1; }; INST_DIR=$(pwd)
d="../../extroot$SUFFIX"; cd "$d"; mkdir -p usr/local; INST_DIR2=$(pwd)
cd ../..
if [ "$PLATFORM" = S7 ]; then CC_DIR="$(pwd)/Saturn7/cross-compiler"; CC_PREF=mipsel-linux
else CC_DIR="$(pwd)/cross-compiler-mipsel"; CC_PREF=mipsel; fi
d=sources; mkdir -p $d; cd $d; SRC_dir=DirectFB-1.2.7; SRC_DIR="$(pwd)/$SRC_dir"

echo 'Note: Copy files from LG TV /usr/local/lib to:'
echo "	$(cd ..; pwd)/DirectFB-LG-usr_local_lib"
echo 'Help: This script install files in extroot. Extract and mount in /usr/local'
echo 'Help: insmod: input-core.ko evdev.ko hid.ko usbhid.ko'
echo 'Help: mknod: /dev/input/event[0123] c 13 6[4567]'
echo 'Help: /usr/local/etc/directfbrc: remove "no-cursor"; add "cursor-update"; add "no-linux-input-grab"'
echo 'Help: In orgm debug menu #14, select #2: "toggle VOSD", and set VOSD[4]=ON'

# download, extract
dir=$SRC_dir
if [ ! -d "$dir" ]; then
	tar=$dir.tar.gz
	read -n1 -p "Press Y to download and extract $tar ... " r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://directfb.org/downloads/Core/DirectFB-1.2/$tar" || exit 3; }
	tar -xzf "$tar"
	exit
fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 11; }
export PATH="$CC_BIN:$PATH"

# config, build
cd "$SRC_DIR"
[ "$1" = bash ] && { bash; exit; }
[ "$1" = noclean ] && shift || { make clean
	if [ "$PLATFORM" = S7 ]; then
	     ./configure --host=$CC_PREF; #--enable-multi; #CFLAGS="-static"
	else ./configure --host=$CC_PREF CFLAGS="-static"; fi; }
[ "$1" = nomake ] && shift || make

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press Y to install in $INST_DIR2/usr/local ... " r; echo; [ "$r" = Y ] || exit
make install DESTDIR="$INST_DIR2"

#	mouse device
#	crw-rw---- 10, 1 /dev/psaux
#	lrw-rw---- 10, 1 /dev/mouse > psaux
# single application core
#	/dev/tty0 /dev/fb0
#	crw-rw---- 29, 0 /dev/fb0
#	crw-r-----  4, 0 /dev/tty0
# multi application core
#	crw-rw---- 29, 0 /dev/fb0
#	crw-rw---- 29, 0 /dev/fusion/0
