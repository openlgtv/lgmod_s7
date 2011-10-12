#!/bin/bash

PLATFORM=S7; #PLATFORM=''
[ "$1" = S6 ] && { shift; PLATFORM=S6; }
[ "$1" = S7 ] && { shift; PLATFORM=S7; }
[ -z "$PLATFORM" ] && { echo "ERROR: $1=<S6|S7>"; exit 1; }
SUFFIX="-$PLATFORM"
[ "$PLATFORM" = S7 ] && SUFFIX=''; # TODO rootfs-S7

cd "${0%/*}"; CONF_DIR=$(pwd)
d="../rootfs$SUFFIX"; cd "$d" || { echo "ERROR: $d not found."; exit 1; }; INST_DIR=$(pwd)
cd ../../..; BB_DIR="$(pwd)/busybox-1.18.5"
if [ "$PLATFORM" = S7 ]; then CC_DIR="$(pwd)/Saturn7/cross-compiler"
else CC_DIR="$(pwd)/cross-compiler-mipsel"; fi

echo 'Note: Busybox Settings->Build Options->Cross Compiler prefix'
if [ "$PLATFORM" = S7 ]; then echo "	../Saturn7/cross-compiler/bin/mipsel-linux-"
else echo "	../${CC_DIR##*/}/bin/mipsel-"; fi

# download, extract
if [ ! -d "$BB_DIR" ]; then
	dir=busybox-1.18.5; tar=$dir.tar.bz2
	read -n1 -p "Press Y to download and extract $tar..." r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://www.busybox.net/downloads/$tar" || exit 3; }
	tar -xvjf "$tar"
	exit
fi
if [ "$PLATFORM" != S7 ]; then
	if [ ! -d "$CC_DIR" ]; then
		dir=cross-compiler-mipsel; tar=$dir.tar.bz2
		read -n1 -p "Press Y to download and extract $tar..." r; echo; [ "$r" = Y ] || exit
		[ -f "$tar" ] || { wget "http://www.uclibc.org/downloads/binaries/0.9.30.1/$tar" || exit 4; }
		tar -xvjf "$tar"
	fi
fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 11; }
[ -d "$BB_DIR" ] || { echo "ERROR: $BB_DIR not found."; exit 12; }
export PATH="$CC_BIN:$PATH"

# config, build
cd "$BB_DIR"
[ "$1" = bash ] && { bash; exit; }
[ "$1" = noclean ] && shift || make clean
[ "$1" = noconfig ] || cp -ax "$CONF_DIR/busybox$SUFFIX.config" ./.config
make menuconfig
[ "$1" = noconfig ] && shift || cp -ax ./.config "$CONF_DIR/busybox$SUFFIX.config"
[ "$1" = nomake ] && shift || make

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press Y to install..." r; echo; [ "$r" = Y ] || exit
make CONFIG_PREFIX="$INST_DIR" install
cd $INST_DIR; svn revert trunk/rootfs/bin/kill trunk/rootfs/bin/watch
