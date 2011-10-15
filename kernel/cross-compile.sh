#!/bin/bash

SUFFIX=''; # TODO

cd "${0%/*}"; CONF_DIR=$(pwd)
d="../rootfs$SUFFIX"; cd "$d" || { echo "ERROR: $d not found."; exit 1; }; INST_DIR=$(pwd)
d="../../extroot$SUFFIX"; cd "$d"; mkdir -p lib/modules; INST_DIR2=$(pwd)
d=../../Saturn7; mkdir -p $d; cd $d
S_dir=GP2_M_CO_FI_2010; K_dir=$S_dir/kernel_src/kernel/linux-2.6.26-saturn7
T_dir=GP2_MSTAR; CC_dir=$T_dir/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl
S_DIR="$(pwd)/$S_dir"; K_DIR="$(pwd)/$K_dir"
T_DIR="$(pwd)/$T_dir"; CC_DIR="$(pwd)/cross-compiler"; CC_PREF=mipsel-linux

# download, extract
if [ ! -d "$S_DIR" ]; then
	dir=$S_dir; tar=$dir.tar.gz.zip
	read -n1 -p "Press Y to download and extract $tar (sources)... " r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget 'http://www.lg.com/global/support/opensource/opensource-file-download.jsp?OPENSOURCE_FILE_NAME=GP2_M_CO_FI_2010.tar.gz&OPENSOURCE_ORIGINAL_NAME=opensourceGLZ%2FGP2_M_CO_FI_2010.tar.gz' \
		-O - > "$tar" || exit 4; }
	unzip "$tar" -d $dir
	mkdir -p src/utils; cp "$S_DIR/u-boot/tools/ccdv" src/utils/; chmod 777 src/utils/ccdv
	cd $dir; tar -xzf kernel.tgz; rm -f kernel.tgz
	cd kernel_src/kernel; tar -xzf linux-2.6.26-saturn7.tgz; rm -f linux-2.6.26-saturn7.tgz
	cp -ax linux-2.6.26-saturn7-svn/config-flash "$K_DIR/.config"
	cd ../../..
	ln -s $K_dir "${K_DIR##*/}"
	exit
fi
if [ ! -d "$T_DIR" ]; then
	dir=$T_dir; tar=${dir}_2.tar.gz
	read -n1 -p "Press Y to download and extract $tar (toolchain)... " r; echo; [ "$r" = Y ] || exit
	[ -f "$tar" ] || { wget 'http://www.lg.com/global/support/opensource/opensource-file-download.jsp?OPENSOURCE_FILE_NAME=GP2_MSTAR_2.tar.gz&OPENSOURCE_ORIGINAL_NAME=opensourceGSZ%2FGP2_MSTAR.tar.gz' \
		-O - > "$tar" || exit 3; }
	tar -xzf "$tar"
	cd "$T_DIR"; tar -xzf toolchian-bin.tgz; rm -f toolchian-bin.tgz; cd ..
	ln -s $CC_dir "${CC_DIR##*/}"
	exit
fi

# environment, config
CC_BIN="$CC_DIR/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 11; }
[ -d "$K_DIR" ] || { echo "ERROR: $K_DIR not found."; exit 12; }
export PATH="$CC_BIN:$PATH"

# config, build
cd "$K_DIR"
[ "$1" = bash ] && { bash; exit; }
[ "$1" = noclean ] && shift
[ "$1" = clean ] && { shift; make clean; }
if [ "$1" = flashcfg ]; then FLASH=1; cp "$CONF_DIR/flash.config" ./.config
else FLASH=''; [ "$1" = noconfig ] || cp "$CONF_DIR/.config" ./; fi
make menuconfig
if [ "$1" = flashcfg ]; then shift; cp -ax ./.config "$CONF_DIR/flash.config"
else [ "$1" = noconfig ] && shift || cp -ax ./.config "$CONF_DIR/"; fi
[ "$1" = nomake ] && shift || make
[ "$1" = nomodules ] && shift || make modules

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press Y to install in $INST_DIR2 and $INST_DIR ... " r; echo; [ "$r" = Y ] || exit
if [ -n "$FLASH" ]; then
	f=uImage; [ -f $f ] && {
		osize=`stat -c%s $f`; o4096=$(( $osize / 4096 * 4096 ))
		[ "$osize" != "$o4096" ] && omore=$(( o4096 + 4096 - osize )) || omore=0
		{ cat $f; for i in `seq $omore`; do printf "\xff"; done; } > "$INST_DIR2/../${f}_flash"
	}; exit; fi
make INSTALL_MOD_STRIP=--strip-unneeded INSTALL_MOD_DIR="$INST_DIR2/lib/modules" modules_install

# install in rootfs
cd "$INST_DIR2/lib/modules"
d="$INST_DIR/lib/modules/"
mv cdc_ether.ko cdc_subset.ko gl620a.ko kaweth.ko mcs7830.ko net1080.ko plusb.ko zaurus.ko "$d"
mv cifs.ko ext2.ko ext3.ko jbd.ko lockd.ko nfs.ko sunrpc.ko "$d"
mv cdrom.ko fuse.ko isofs.ko rndis_host.ko sr_mod.ko "$d"
mv uinput.ko evdev.ko hid.ko usbhid.ko "$d"; f=input-core.ko; [ -f $f ] && mv $f "$d"
