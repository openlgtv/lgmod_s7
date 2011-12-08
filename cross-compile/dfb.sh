#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)
note dfb
echo 'Help: This script install files in extroot. Extract and mount in /usr/local (do not override LG files)'
echo 'Help: insmod: input-core.ko evdev.ko hid.ko usbhid.ko'
#echo 'Done: mknod: /dev/input/event[0123] c 13 6[4567]'
#echo 'Done: /usr/local/etc/directfbrc: remove "no-cursor"; add "cursor-update"; add "no-linux-input-grab"'
echo 'Help: In orgm debug menu #14, select #2: "toggle VOSD", and set VOSD[4]=ON'

# download, extract
get 'http://downloads.sourceforge.net/project/libpng/zlib/1.2.3/zlib-1.2.3.tar.gz'
get 'http://downloads.sourceforge.net/project/libpng/libpng12/older-releases/1.2.29/libpng-1.2.29.tar.gz'
get 'http://directfb.org/downloads/Core/DirectFB-1.2/DirectFB-1.2.7.tar.gz'

# config, build, install
#Configure() { ./configure "$@" --enable-multi; }
build CONF+=dfb inst='ext make install' "$@"; # always respect cmd line params

# devices
#	crw-rw---- 10, 1 /dev/psaux
#	lrw-rw---- 10, 1 /dev/mouse > psaux
# single application core
#	/dev/tty0 /dev/fb0
#	crw-rw---- 29, 0 /dev/fb0
#	crw-r-----  4, 0 /dev/tty0
# multi application core
#	crw-rw---- 29, 0 /dev/fb0
#	crw-rw---- 29, 0 /dev/fusion/0
