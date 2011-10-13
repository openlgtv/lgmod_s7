#!/bin/bash

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
d=sources; mkdir -p $d; cd $d; SRC_dir=libupnp-1.6.6; SRC_DIR="$(pwd)/$SRC_dir"

# download, extract
dirp=djmount-large5
if [ ! -d "$dirp" ]; then
	tar=$dirp.zip
	read -n1 -p "Press Y to download and extract $tar ... " r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://www.mediafire.com/file/wmnk2xz11ki/$tar" || exit 4; }
	unzip "$tar"
	exit
fi
dir=$SRC_dir
if [ ! -d "$dir" ]; then
	tar=$dir.tar.bz2
	read -n1 -p "Press Y to download and extract $tar ... " r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://sourceforge.net/projects/pupnp/files/pupnp/libUPnP 1.6.6/$tar" || exit 3; }
	tar -xjf "$tar"
	cd $dir; ln -s build-aux config.aux
	patch -p1 -i ../$dirp/libupnp.patch; cd ..
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
	     ./configure --host=$CC_PREF --disable-debug --disable-samples
	else ./configure --host=$CC_PREF --disable-debug --disable-samples; fi; }
[ "$1" = nomake ] && shift || make

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press Y to install in $INST_DIR ... " r; echo; [ "$r" = Y ] || exit
d="$INST_DIR/usr/lib/"
for i in upnp/.libs/libupnp.so ixml/.libs/libixml.so threadutil/.libs/libthreadutil.so; do
	cp -ax $i* "$d"; "$CC_BIN/mipsel-linux-strip" --strip-unneeded "$d${i##*/}"*; ls -l "$d${i##*/}"*; done
