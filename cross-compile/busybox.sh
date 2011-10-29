#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)
echo 'Note: Busybox Settings->Build Options->Cross Compiler prefix'
echo "	../$CC_dir/bin/$CC_PREF-"

# download, extract
if [ "$PLATFORM" != S7 ]; then get 'http://www.uclibc.org/downloads/binaries/0.9.30.1/$CC_dir.tar.bz2'
fi; get 'http://www.busybox.net/downloads/busybox-1.18.5.tar.gz'

# config, build, install
Configure() {
	if [ -n "$CFG" ]; then cp "$CONF_DIR/busybox$SUFFIX.config" .config || exit $?
	fi; make menuconfig; err=$?
	if [ -n "$CFG" ]; then cp -ax .config "$CONF_DIR/busybox$SUFFIX.config" || exit $?
	fi; return $err; }
Install() { make CONFIG_PREFIX="$1" install; cd $1
	if [ "$PLATFORM" != S7 ]; then :; #rm bin/powertop
	else svn revert bin/kill; svn revert bin/watch; #rm usr/bin/kbd_mode
	fi; }
build CFG inst='root make ' "$@"; # always respect cmd line params
