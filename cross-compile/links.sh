#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m, djpety

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
#if [ "$PLATFORM" = S7 ]; then CC_DFB="$(pwd)/Saturn7/GP2_MSTAR/directFB"
#else CC_DFB="$(pwd)/Saturn6/GP1_MSTAR/directFB"; fi
d=sources; mkdir -p $d; cd $d; SRC_dir=links-2.3; SRC_DIR="$(pwd)/$SRC_dir"

echo 'Note: Copy files from LG TV /usr/local/lib to:'
echo "	$(cd ..; pwd)/DirectFB-LG-usr_local_lib"

# download, extract
dir=$SRC_dir
if [ ! -d "$dir" ]; then
	tar=$dir.tar.gz
	read -n1 -p "Press Y to download and extract $tar ... " r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://links.twibright.com/download/$tar" || exit 3; }
	tar -xzf "$tar"
	exit
fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 11; }
[ -d "$SRC_DIR" ] || { echo "ERROR: $SRC_DIR not found."; exit 12; }
export PATH="$CC_BIN:$PATH"
cd "$SRC_DIR"
export CC=$CC_PREF-gcc
#export DIRECTFB_CFLAGS="-I$CC_DFB/include -I$CC_DFB/lib -D_REENTRANT"
#export DIRECTFB_LIBS="-L${SRC_DIR%/*}/DirectFB-LG-usr_local_lib -ldirectfb -lfusion -ldirect -lpthread"

# config, build
[ "$1" = bash ] && { bash; exit; }
[ "$1" = noclean ] && shift || { make clean
	if [ "$PLATFORM" = S7 ]; then
	     ./configure --host=$CC_PREF; #CFLAGS="-static"; #--with-directfb --enable-graphics
	else ./configure --host=$CC_PREF; CFLAGS="-static"; fi; }
[ "$1" = nomake ] && shift || make

# install
[ "$1" = noinstall ] && exit
dest() { for i in "$@"; do "$CC_BIN/$CC_PREF-strip" --strip-unneeded "$i"; file "$i"; ls -l "$i"; done; }
read -n1 -p "Press Y to install in $INST_DIR ... " r; echo; [ "$r" = Y ] || exit
d="$INST_DIR2/usr/bin/"
for i in links; do
	f="$d$i"; cp -ax $i "$f"; dest "$f"; done
