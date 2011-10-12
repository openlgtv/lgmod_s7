#!/bin/bash

cd "${0%/*}"; CONF_DIR=$(pwd)
d=../rootfs; cd $d || { echo "ERROR: $d not found."; exit 1; }; INST_DIR=$(pwd)
cd ../../..; BB_DIR="$(pwd)/busybox-1.18.5"
#CC_DIR="$(pwd)/cross-compiler-mipsel"
CC_DIR="$(pwd)/Saturn7/cross-compiler"

echo 'Note: Busybox Settings->Build Options->Cross Compiler prefix'
#echo "	../${CC_DIR##*/}/bin/mipsel-"
echo "	../Saturn7/cross-compiler/bin/mipsel-linux-"

# download, extract
if [ ! -d "$BB_DIR" ]; then
	dir=busybox-1.18.5; tar=$dir.tar.bz2
	read -n1 -p "Press Y to download and extract $tar..." r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://www.busybox.net/downloads/$tar" || exit 3; }
	tar -xvjf "$tar"
	exit
fi
#if [ ! -d "$CC_DIR" ]; then
#	dir=cross-compiler-mipsel; tar=$dir.tar.bz2
#	read -n1 -p "Press Y to download and extract $tar..." r; echo; [ "$r" = Y ] || exit
#	[ -f "$tar" ] || { wget "http://www.uclibc.org/downloads/binaries/0.9.30.1/$tar" || exit 4; }
#	tar -xvjf "$tar"
#fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 11; }
[ -d "$BB_DIR" ] || { echo "ERROR: $BB_DIR not found."; exit 12; }
export PATH="$CC_BIN:$PATH"

# config, build
cd "$BB_DIR"
[ "$1" = bash ] && { bash; exit; }
[ "$1" = clean ] && { shift; make clean; }
[ "$1" = noconfig ] || cp -ax "$CONF_DIR/.config" ./
make menuconfig
[ "$1" = noconfig ] && shift || cp -ax ./.config "$CONF_DIR/"
[ "$1" = nomake ] && shift || make

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press Y to install..." r; echo; [ "$r" = Y ] || exit
make CONFIG_PREFIX="$INST_DIR" install
cd $INST_DIR; svn revert trunk/rootfs/bin/kill trunk/rootfs/bin/watch
