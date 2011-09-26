#!/bin/bash

cd "${0%/*}"; CONF_DIR=$(pwd)
cd "../rootfs"; INST_DIR=$(pwd)
cd "../../.."

CC_DIR="$(pwd)/cross-compiler-mipsel"
BB_DIR="$(pwd)/busybox-1.18.5"

# download, extract
if [ ! -d "$CC_DIR" ]; then
	tar=cross-compiler-mipsel.tar.bz2
	read -n1 -p "Press any key to download and extract $tar..."
	[ ! -f "$tar" ] || wget "http://www.uclibc.org/downloads/binaries/0.9.30.1/$tar"
	tar -xvjf "$tar"
fi
if [ ! -d "$BB_DIR" ]; then
	tar=busybox-1.18.5.tar.bz2
	read -n1 -p "Press any key to download and extract $tar..."
	[ ! -f "$tar" ] || wget "http://www.busybox.net/downloads/$tar"
	tar -xvjf "$tar"
fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 1; }
[ -d "$BB_DIR" ] || { echo "ERROR: $BB_DIR not found."; exit 2; }
export PATH="$CC_BIN:$PATH"
echo 'Note: Busybox Settings->Build Options->Cross Compiler prefix'
echo "	../${CC_DIR##*/}/bin/mipsel-"

# config, build, install
cd "$BB_DIR"
[ "$1" = bash ] && { bash; exit; }
[ "$1" = noclean ] || make clean
cp -ax "$CONF_DIR/.config" ./
make menuconfig
cp -ax ./.config "$CONF_DIR/"
make 
read -n1 -p "Press any key to install..."
make CONFIG_PREFIX="$INST_DIR" install
