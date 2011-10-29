#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)

# download, extract
get 'http://svn.openlgtv.org.ru/s6_s7_modules' act=svn

# config, build, install
Clean() { make clean; cd pty; make clean; cd ..; cd mini_fo; make clean; cd ..; }
Make() { make CROSS_COMPILE=$CC_PREF- KDIR="$K_DIR" || exit 1; cd pty
	make CROSS_COMPILE=$CC_PREF- KDIR="$K_DIR" || exit 1; cd ../mini_fo
	make CROSS_COMPILE=$CC_PREF- KDIR="$K_DIR" || exit 1; cd ..; }
Install() { INST_dest "$1/lib/modules/2.6.26/" pty/pty.ko mini_fo/mini_fo.ko
	INST_src_dst asix.ko "$INST_EXT/lib/modules/asix-lgmod.ko" dm9601.ko "$1/lib/modules/dm9601-lgmod.ko" \
		pegasus.ko "$INST_EXT/lib/modules/pegasus-lgmod.ko" mcs7830.ko "$INST_EXT/lib/modules/mcs7830-lgmod.ko"; }
build noconf inst='root dest ' "$@"; # always respect cmd line params
