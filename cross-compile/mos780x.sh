#!/bin/bash

PLATFORM=S7; #PLATFORM=''
[ "$1" = S6 ] && { shift; PLATFORM=S6; }
[ "$1" = S7 ] && { shift; PLATFORM=S7; }
[ -z "$PLATFORM" ] && { echo "ERROR: $1=<S6|S7>"; exit 1; }
SUFFIX="-$PLATFORM"
[ "$PLATFORM" = S7 ] && SUFFIX=''; # TODO rootfs-S7

cd "${0%/*}"; CONF_DIR=$(pwd)
d="../rootfs$SUFFIX"; cd "$d" || { echo "ERROR: $d not found."; exit 1; }; INST_DIR=$(pwd)
d="../../extroot$SUFFIX"; cd "$d"; mkdir -p lib/modules; INST_DIR2=$(pwd)
cd ../..
if [ "$PLATFORM" = S7 ]; then CC_DIR="$(pwd)/Saturn7/cross-compiler"; CC_PREF=mipsel-linux
else CC_DIR="$(pwd)/cross-compiler-mipsel"; CC_PREF=mipsel; fi
if [ "$PLATFORM" = S7 ]; then K_DIR="$(pwd)/Saturn7/GP2_M_CO_FI_2010/kernel_src/kernel/linux-2.6.26-saturn7"
else K_DIR="$(pwd)/Saturn6/GP1_M_CO_FI_2010/kernel_src/kernel/linux-2.6.26-saturn6"; fi
d=sources; mkdir -p $d; cd $d; SRC_dir=MCS780x_Linux_driver_v1.11; SRC_DIR="$(pwd)/$SRC_dir"

# download, extract
dir=$SRC_dir
if [ ! -d "$dir" ]; then
	tar=$dir.zip
	read -n1 -p "Press Y to download and extract $tar ... " r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://www.asix.com.tw/FrootAttach/driver/$tar" || exit 3; }
	unzip "$tar" #-d $dir
	exit
fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 11; }
export PATH="$CC_BIN:$PATH"

# config, build
cd "$SRC_DIR"
[ "$1" = bash ] && { bash; exit; }
[ "$1" = noclean ] && shift || make clean
[ "$1" = nomake ] && shift || make CROSS_COMPILE=$CC_PREF- KDIR="$K_DIR"

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press Y to install in $INST_DIR2 and $INST_DIR ... " r; echo; [ "$r" = Y ] || exit
d="$INST_DIR/lib/modules/"; d2="$INST_DIR2/lib/modules/"; s='-asix.ko'
i=mcs7830; f="$d2$i$s"; cp -ax $i.ko "$f"; "$CC_BIN/$CC_PREF-strip" --strip-unneeded "$f"; ls -l "$f"
	#mv "$f" "$d"; # install in rootfs
