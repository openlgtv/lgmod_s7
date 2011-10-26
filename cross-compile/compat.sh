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
d="../../extroot$SUFFIX"; cd "$d"; INST_DIR2=$(pwd)
cd ../..
if [ "$PLATFORM" = S7 ]; then CC_DIR="$(pwd)/Saturn7/cross-compiler"; CC_PREF=mipsel-linux
else CC_DIR="$(pwd)/cross-compiler-mipsel"; CC_PREF=mipsel; fi

if [ "$PLATFORM" = S7 ]; then K_DIR="$(pwd)/Saturn7/GP2_M_CO_FI_2010/kernel_src/kernel/linux-2.6.26-saturn7"
else K_DIR="$(pwd)/Saturn6/GP1_M_CO_FI_2010/kernel_src/kernel/linux-2.6.26-saturn6"; fi

d=sources; mkdir -p $d; cd $d; SRC_dir=compat-wireless-3.0-2; SRC_DIR="$(pwd)/$SRC_dir"

# download, extract
dir=$SRC_dir
if [ ! -d "$dir" ]; then
	tar=$dir.tar.bz2
	read -n1 -p "Press Y to download and extract $tar ... " r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget "http://www.orbit-lab.org/kernel/compat-wireless-3.0-stable/v3.0/$tar" || exit 3; }
	tar -xjf "$tar"
	patch -p1 -i "$CONF_DIR/compat_build.patch"
	exit
fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 11; }
[ -d "$SRC_DIR" ] || { echo "ERROR: $SRC_DIR not found."; exit 12; }
export PATH="$CC_BIN:$PATH"
cd "$SRC_DIR"

# config, build
[ "$1" = bash ] && { bash; exit; }
[ "$1" = noclean ] && shift || make "KLIB=$K_DIR" "KLIB_BUILD=$K_DIR" clean; #distclean
[ "$1" = nomake ] && shift || make "KLIB=$K_DIR" "KLIB_BUILD=$K_DIR"

# install
[ "$1" = noinstall ] && exit
dest() { for i in "$@"; do "$CC_BIN/$CC_PREF-strip" --strip-unneeded "$i"; file "$i"; ls -l "$i"; done; }
read -n1 -p "Press Y to install in $INST_DIR2 and $INST_DIR ... " r; echo; [ "$r" = Y ] || exit
d="$INST_DIR/lib/modules/2.6.26/compat/"; d2="$INST_DIR2/lib/modules/compat/"; mkdir -p "$d2"
for i in `find . -type f | grep ko$`; do
	f="$d2${i##*/}"; cp -ax "$i" "$f"; dest "$f"
		#mv "$f" "$d"; # install in rootfs
done
