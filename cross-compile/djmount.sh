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
d=sources; mkdir -p $d; cd $d; SRC_DIR="$(pwd)/djmount-0.71"

# download, extract
if [ ! -d "$SRC_DIR" ]; then
	dirp=djmount-large5; tar=$dirp.zip
	read -n1 -p "Press Y to download and extract $tar..." r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://www.mediafire.com/file/wmnk2xz11ki/$tar" || exit 4; }
	unzip "$tar"
	dir=djmount-0.71; tar=$dir.tar.gz
	read -n1 -p "Press Y to download and extract $tar..." r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://sourceforge.net/projects/djmount/files/djmount/0.71/$tar" || exit 3; }
	tar -xzf "$tar"
	cd $dir; mv libupnp libupn_org; ln -s ../libupnp-1.6.6 libupnp
	patch -p1 -i ../$dirp/djmount.patch; cd ..
	exit
fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 11; }
export PATH="$CC_BIN:$PATH"

# config, build
cd "$SRC_DIR"
export FUSE_LIBS="-L${SRC_DIR%/*}/fuse-2.8.6/lib/.libs -lfuse -pthread -ldl"
export FUSE_CFLAGS="-I${SRC_DIR%/*}/fuse-2.8.6/include -D_FILE_OFFSET_BITS=64"
[ "$1" = bash ] && { bash; exit; }
[ "$1" = noclean ] && shift || { make clean
	if [ "$PLATFORM" = S7 ]; then
	     ./configure --host=$CC_PREF --disable-debug --disable-charset
	else ./configure --host=$CC_PREF --disable-debug --disable-charset; fi; }
[ "$1" = nomake ] && shift || {
	if [ "$PLATFORM" = S7 ]; then make; # LDFLAGS+="-all-static"
	else make LDFLAGS+="-all-static"; fi; }

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press Y to install..." r; echo; [ "$r" = Y ] || exit
for i in djmount; do d="$INST_DIR/usr/bin/"
	f="$d$i"; cp -ax $i "$d"; "$CC_BIN/$CC_PREF-strip" --strip-unneeded "$f"; ls -l "$f"; done
