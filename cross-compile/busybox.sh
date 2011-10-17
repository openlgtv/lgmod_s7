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
if [ "$PLATFORM" = S7 ]; then CC_dir=Saturn7/cross-compiler; CC_DIR="$(pwd)/$CC_dir"; CC_PREF=mipsel-linux
#else CC_dir=Saturn6/mipsel-gcc-4.1.2-uclibc-0.9.28.3-mips32; CC_DIR="$(pwd)/$CC_dir"; CC_PREF=mipsel-linux; fi
else CC_dir=cross-compiler-mipsel; CC_DIR="$(pwd)/$CC_dir"; CC_PREF=mipsel; fi
d=sources; mkdir -p $d; cd $d; SRC_dir=busybox-1.18.5; SRC_DIR="$(pwd)/$SRC_dir"

echo 'Note: Busybox Settings->Build Options->Cross Compiler prefix'
echo "	../../$CC_dir/bin/$CC_PREF-"

# download, extract
dir=$SRC_dir
if [ ! -d "$dir" ]; then
	tar=$dir.tar.bz2
	read -n1 -p "Press Y to download and extract $tar ... " r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://www.busybox.net/downloads/$tar" || exit 3; }
	tar -xvjf "$tar"
	exit
fi
if [ "$PLATFORM" != S7 ]; then
	if [ ! -d "$CC_DIR" ]; then
		cd "${CC_DIR%/*}"
		dir=$CC_dir; tar=$dir.tar.bz2
		read -n1 -p "Press Y to download and extract $tar ... " r; echo; [ "$r" = Y ] || exit
		#[ -f "$tar" ] || { wget "http://dl.dropbox.com/u/490148/LGLib/v2/$tar" || exit 4; }
		[ -f "$tar" ] || { wget "http://www.uclibc.org/downloads/binaries/0.9.30.1/$tar" || exit 4; }
		tar -xvjf "$tar"
		cd "${SRC_DIR%/*}"
		exit
	fi
fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 11; }
[ -d "$SRC_DIR" ] || { echo "ERROR: $SRC_DIR not found."; exit 12; }
export PATH="$CC_BIN:$PATH"
cd "$SRC_DIR"

# config, build
[ "$1" = bash ] && { bash; exit; }
[ "$1" = noclean ] && shift || make clean
[ "$1" = noconfig ] || cp "$CONF_DIR/busybox$SUFFIX.config" ./.config
make menuconfig
[ "$1" = noconfig ] && shift || cp -ax ./.config "$CONF_DIR/busybox$SUFFIX.config"
[ "$1" = nomake ] && shift || make

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press Y to install in $INST_DIR ... " r; echo; [ "$r" = Y ] || exit
make CONFIG_PREFIX="$INST_DIR" install
if [ "$PLATFORM" = S7 ]; then
	cd $INST_DIR; svn revert bin/kill; svn revert bin/watch
elif [ "$PLATFORM" = S6 ]; then
	cd $INST_DIR; svn del bin/powertop
fi
