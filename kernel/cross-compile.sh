#!/bin/bash

cd "${0%/*}"; CONF_DIR=$(pwd)
cd "../rootfs"; INST_DIR=$(pwd)
cd "../../extroot"; INST_DIR2=$(pwd)
cd "../../s6_s7_modules"; MODS_DIR=$(pwd); MODS_EXT='pty mini_fo'
cd "../Saturn7"

CC_DIR="$(pwd)/GP2_MSTAR"
S7_DIR="$(pwd)/GP2_M_CO_FI_2010"
K_DIR="$S7_DIR/kernel_src/kernel/linux-2.6.26-saturn7"

# download, extract
if [ ! -d "$CC_DIR" ]; then
	tar=GP2_MSTAR_2.tar.gz
	read -n1 -p "Press any key to download and extract $tar (toolchain)..."
	[ ! -f "$tar" ] || wget 'http://www.lg.com/global/support/opensource/opensource-file-download.jsp?OPENSOURCE_FILE_NAME=GP2_MSTAR_2.tar.gz&OPENSOURCE_ORIGINAL_NAME=opensourceGSZ%2FGP2_MSTAR.tar.gz' \
		-O - > "$tar"
	tar -xvjf "$tar"
	cd "$CC_DIR"; tar -xvzf toolchian-bin.tgz; rm -f toolchian-bin.tgz; cd ..
fi
if [ ! -d "$S7_DIR" ]; then
	tar=GP2_M_CO_FI_2010.tar.gz.zip
	read -n1 -p "Press any key to download and extract $tar (sources)..."
	[ ! -f "$tar" ] || wget 'http://www.lg.com/global/support/opensource/opensource-file-download.jsp?OPENSOURCE_FILE_NAME=GP2_M_CO_FI_2010.tar.gz&OPENSOURCE_ORIGINAL_NAME=opensourceGLZ%2FGP2_M_CO_FI_2010.tar.gz' \
		-O - > "$tar"
	unzip "$tar" -d GP2_M_CO_FI_2010
	mkdir -p src/utils; cp "$S7_DIR/u-boot/tools/ccdv" src/utils/; chmod 777 src/utils/ccdv
	cd GP2_M_CO_FI_2010; tar -xvzf kernel.tgz; rm -f kernel.tgz
	cd kernel_src/kernel; tar -xvzf linux-2.6.26-saturn7.tgz; rm -f linux-2.6.26-saturn7.tgz
	cp -ax linux-2.6.26-saturn7-svn/config-flash "$K_DIR/.config"
	cd ../../..
fi

# environment, config
CC_BIN="$CC_DIR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin"
[ -d "$CC_BIN" ] || { echo "ERROR: $CC_BIN not found."; exit 1; }
[ -d "$K_DIR" ] || { echo "ERROR: $K_DIR not found."; exit 2; }
export PATH="$CC_BIN:$PATH"
echo 'Note: Copy new modules sources:'
echo "	cp -ax '$MODS_DIR'/*.[ch] '$K_DIR/drivers/net/usb/'"

# config, build
cd "$K_DIR"
[ "$1" = bash ] && { bash; exit; }
[ "$1" = clean ] && { shift; make clean
	for i in $MODS_EXT; do
		( cd "$MODS_DIR/$i"; make clean ); done; }
[ "$1" = noconfig ] || cp -ax "$CONF_DIR/.config" ./
make menuconfig
[ "$1" = noconfig ] && shift || cp -ax ./.config "$CONF_DIR/"
[ "$1" = nomake ] && shift || make
[ "$1" = nomodules ] && shift || {
	make modules
	for i in $MODS_EXT; do
		( cd "$MODS_DIR/$i"
		make CROSS_COMPILE=mipsel-linux- "KERNEL_SRC=$K_DIR")
	done; }

# install
[ "$1" = noinstall ] && exit
read -n1 -p "Press any key to install..."
make INSTALL_MOD_STRIP=--strip-unneeded INSTALL_MOD_DIR="$INST_DIR2/lib/modules" modules_install
for i in $MODS_EXT; do
	cp -ax "$MODS_DIR/$i/$i.ko" "$INST_DIR2/lib/modules/"
	"$CC_BIN/mipsel-linux-strip" --strip-unneeded "$INST_DIR2/lib/modules/$i.ko"; done

# install in rootfs
cd "$INST_DIR2/lib/modules"
mv cdc_ether.ko cdc_subset.ko dm9601.ko gl620a.ko kaweth.ko mcs7830.ko net1080.ko plusb.ko zaurus.ko "$INST_DIR/lib/modules/"
mv cifs.ko ext2.ko ext3.ko jbd.ko lockd.ko nfs.ko sunrpc.ko "$INST_DIR/lib/modules/"
mv cdrom.ko fuse.ko isofs.ko rndis_host.ko sr_mod.ko "$INST_DIR/lib/modules/"
mv uinput.ko input-core.ko evdev.ko "$INST_DIR/lib/modules/"
mv mini_fo.ko pty.ko "$INST_DIR/lib/modules/"
