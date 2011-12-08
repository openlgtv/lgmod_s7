#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)

# download, extract
if [ "$PLATFORM" = S7 ]; then
	cd ..; mkdir -p Saturn7; CD Saturn7 || exit $?
	get_cc() { f='toolchian-bin.tgz'; get CC $f dir=gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl && CD .. && rm -f toolchian-bin.tgz || exit $?
		ln -s GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl ../cross-compiler || exit $?; }
	get CC 'http://www.lg.com/global/support/opensource/opensource-file-download.jsp?OPENSOURCE_FILE_NAME=GP2_MSTAR_2.tar.gz&OPENSOURCE_ORIGINAL_NAME=opensourceGSZ%2FGP2_MSTAR.tar.gz' \
		tar=GP2_MSTAR_2.tar.gz dir=GP2_MSTAR run=get_cc

	CD .. || exit $?
	get_k() { mkdir -p ../src/utils && cp -a u-boot/tools/ccdv ../src/utils/ && chmod +x ../src/utils/ccdv || exit $?
		f='kernel.tgz'; get CC $f dir=kernel_src && rm -f ../$f && CD kernel || exit $?
		f='linux-2.6.26-saturn7.tgz'; get CC $f && rm -f ../$f || exit $?
		#cp -ax ../linux-2.6.26-saturn7-svn/config-flash .config || exit $?
		ln -s GP2_M_CO_FI_2010/kernel_src/kernel/linux-2.6.26-saturn7 ../../../../ || exit $?; }
	get CC 'http://www.lg.com/global/support/opensource/opensource-file-download.jsp?OPENSOURCE_FILE_NAME=GP2_M_CO_FI_2010.tar.gz&OPENSOURCE_ORIGINAL_NAME=opensourceGLZ%2FGP2_M_CO_FI_2010.tar.gz' \
		tar=GP2_M_CO_FI_2010.tar.gz.zip dir=GP2_M_CO_FI_2010 act=zip run=get_k
	# Note:
	#$ Saturn7/cross-compiler/bin/mipsel-linux-gcc -print-search-dirs
	#install
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../lib/gcc/mipsel-lg-linux-gnu/4.3.2/
	#programs
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../libexec/gcc/mipsel-lg-linux-gnu/4.3.2/
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../libexec/gcc/
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../lib/gcc/mipsel-lg-linux-gnu/4.3.2/../../../../mipsel-lg-linux-gnu/bin/mipsel-lg-linux-gnu/4.3.2/
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../lib/gcc/mipsel-lg-linux-gnu/4.3.2/../../../../mipsel-lg-linux-gnu/bin/
	#libraries
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../lib/gcc/mipsel-lg-linux-gnu/4.3.2/
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../lib/gcc/
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../lib/gcc/mipsel-lg-linux-gnu/4.3.2/../../../../mipsel-lg-linux-gnu/lib/mipsel-lg-linux-gnu/4.3.2/
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../lib/gcc/mipsel-lg-linux-gnu/4.3.2/../../../../mipsel-lg-linux-gnu/lib/
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../mipsel-lg-linux-gnu//sys-root/lib/mipsel-lg-linux-gnu/4.3.2/
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../mipsel-lg-linux-gnu//sys-root/lib/
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../mipsel-lg-linux-gnu//sys-root/usr/lib/mipsel-lg-linux-gnu/4.3.2/
	#/home/LG32LD465/Saturn7/GP2_MSTAR/gp2-s7-mipsel-lg-gcc-4.3.2-glibc-2.9-nptl/bin/../mipsel-lg-linux-gnu//sys-root/usr/lib/
else
	echo 'TODO'; exit 13; # TODO: S6
fi; CD "$K_DIR" || exit $?

# config, build, install
Configure() {
	if [ -n "$FLASH" ]; then cp "$CONF_DIR/kernel$SUFFIX.flash" .config || exit $?
	elif [ -n "$CFG" ]; then cp "$CONF_DIR/kernel$SUFFIX.config" .config || exit $?
	fi; make menuconfig; err=$?
	if [ -n "$FLASH" ]; then cp -ax .config "$CONF_DIR/kernel$SUFFIX.flash" || exit $?
	elif [ -n "$CFG" ]; then cp -ax .config "$CONF_DIR/kernel$SUFFIX.config" || exit $?
	fi; return $err; }
Make() { if [ -z "$modules" ]; then make; else make modules; fi; }
Install() { if [ -n "$FLASH" ]; then
		f=uImage; [ -f $f ] || return 1
		osize=`stat -c%s $f`; o4096=$(( $osize / 4096 * 4096 ))
		[ "$osize" != "$o4096" ] && omore=$(( o4096 + 4096 - osize )) || omore=0
		{ cat $f; for i in `seq $omore`; do printf "\xff"; done; } > "$1/../lgmod_S7_$f"
	else
		make INSTALL_MOD_STRIP=--strip-unneeded INSTALL_MOD_DIR="$1/lib/modules" modules_install
		CD "$1/lib/modules" || exit $?
		INST_dest "$INST_DIR/lib/modules/2.6.26/" crc-itu-t.ko firmware_class.ko led-class.ko \
			cdc_ether.ko cdc_subset.ko gl620a.ko kaweth.ko net1080.ko plusb.ko zaurus.ko rndis_host.ko \
			ext2.ko jbd.ko ext3.ko cifs.ko sunrpc.ko lockd.ko nfs.ko fuse.ko isofs.ko cdrom.ko sr_mod.ko \
			uinput.ko evdev.ko hid.ko usbhid.ko input-core.ko
		INST_dest "$INST_DIR/lib/modules/2.6.26/wireless/" rt2500usb.ko rt2x00lib.ko rt2x00usb.ko rt73usb.ko zd1211rw.ko
	fi; }
build noclean CFG inst='ext make ' "$@"; # always respect cmd line params

# create modules.dep - TODO
#if [ -f "$K_DIR/System.map" ]; then
#	cd "$INST_DIR"; d=lib/modules; v=2.6.26; D=$d/$v; E=$D/extroot$SUFFIX
#	rm $E; ln -s ../../../../extroot/$d $E
#	depmod -n -e -F "$K_DIR/System.map" -C <(echo search .) -b . $v > ../../depmod.out
#	svn revert $E || { rm $E; ln -s /mnt/lg/user/extroot/$d $E; }
#	cat ../../depmod.out | grep '\.ko:' > $D/modules.dep
#fi
