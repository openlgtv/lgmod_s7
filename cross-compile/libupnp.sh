#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)

# download, extract
get 'http://www.mediafire.com/file/wmnk2xz11ki/djmount-large5.zip'
DIRP="$(pwd)"
get_upnp() { ln -s build-aux config.aux; patch -p1 -i "$DIRP/libupnp.patch"; }
get 'http://downloads.sourceforge.net/project/pupnp/files/pupnp/libUPnP 1.6.6/libupnp-1.6.6.tar.bz2' run=get_upnp

# config, build, install
Configure() { ./configure "$@" --disable-debug --disable-samples; }
Install() { INST_dest "$1/usr/lib/" upnp/.libs/libupnp.so* ixml/.libs/libixml.so* threadutil/.libs/libthreadutil.so*; }
i=''; [ "$PLATFORM" != S7 ] && i=noinstall
build inst='root dest ' "$@"; # always respect cmd line params
