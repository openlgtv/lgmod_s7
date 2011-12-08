#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)

# download, extract
get 'http://downloads.sourceforge.net/project/fuse/files/fuse-2.X/2.8.6/fuse-2.8.6.tar.gz'

# config, build, install
Configure() { ./configure "$@" --disable-example --disable-mtab; }
Install() { INST_dest "$1/usr/lib/" lib/.libs/libfuse.so* lib/.libs/libulockmgr.so*
	INST_dest "$1/usr/bin/" util/fusermount util/mount.fuse util/ulockmgr_server; }
i=''; [ "$PLATFORM" != S7 ] && i=noinstall
build $i inst='root dest ' "$@"; # always respect cmd line params
