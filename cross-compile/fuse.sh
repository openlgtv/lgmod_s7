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
d=sources; mkdir -p $d; cd $d; SRC_DIR="$(pwd)/fuse-2.8.6"

# download, extract
if [ ! -d "$SRC_DIR" ]; then
	dir=fuse-2.8.6; tar=$dir.tar.gz
	read -n1 -p "Press Y to download and extract $tar..." r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://sourceforge.net/projects/fuse/files/fuse-2.X/2.8.6/$tar" || exit 3; }
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
	     ./configure --host=$CC_PREF --disable-example --disable-mtab --prefix="$CC_DIR"
	else ./configure --host=$CC_PREF --disable-example --prefix="$CC_DIR"; fi; }
[ "$1" = nomake ] && shift || make

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press Y to install..." r; echo; [ "$r" = Y ] || exit
for i in lib/.libs/libfuse.so lib/.libs/libulockmgr.so; do d="$INST_DIR/usr/lib/"
	cp -ax $i* "$d"; "$CC_BIN/mipsel-linux-strip" --strip-unneeded "$d${i##*/}"*; ls -l "$d${i##*/}"*; done
for i in ulockmgr_server mount.fuse fusermount; do d="$INST_DIR/usr/bin/"
	f="$d$i"; cp -ax $i "$d"; "$CC_BIN/$CC_PREF-strip" --strip-unneeded "$f"; ls -l "$f"; done
