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
if [ "$PLATFORM" = S7 ]; then CC_DFB="$(pwd)/Saturn7/GP2_MSTAR/directFB"
else CC_DFB="$(pwd)/Saturn6/GP1_MSTAR/directFB"; fi
d=sources; mkdir -p $d; cd $d; SRC_dir=LiTE-0.8.10; SRC_DIR="$(pwd)/$SRC_dir"

echo 'Note: Copy files from LG TV /usr/local/lib to:'
echo "	$(cd ..; pwd)/DirectFB-LG-usr_local_lib"

# download, extract
dir=$SRC_dir
if [ ! -d "$dir" ]; then
	tar=$dir.tar.gz
	read -n1 -p "Press Y to download and extract $tar ... " r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://directfb.org/downloads/Libs/$tar" || exit 3; }
	tar -xzf "$tar"
	exit
fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 11; }
export PATH="$CC_BIN:$PATH"
export DFB_CFLAGS="-I$CC_DFB/include -I$CC_DFB/lib -D_REENTRANT"
export DFB_LIBS="-L${SRC_DIR%/*}/DirectFB-LG-usr_local_lib -ldirectfb -lfusion -ldirect -lpthread"

# config, build
cd "$SRC_DIR"
[ "$1" = bash ] && { bash; exit; }
[ "$1" = noclean ] && shift || { make clean
	if [ "$PLATFORM" = S7 ]; then
	     ./configure --host=$CC_PREF; #CFLAGS="-static"
	else ./configure --host=$CC_PREF; CFLAGS="-static"; fi; }
[ "$1" = nomake ] && shift || make

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press Y to install in $INST_DIR2/usr/local ... " r; echo; [ "$r" = Y ] || exit
make install DESTDIR="$INST_DIR2"
