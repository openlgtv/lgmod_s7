#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)

# download, extract
get 'http://downloads.sourceforge.net/project/fuse/files/fuse-2.X/2.8.6/fuse-2.8.6.tar.gz'
DIRF="$(pwd)"
get 'http://www.mediafire.com/file/wmnk2xz11ki/djmount-large5.zip'
DIRP="$(pwd)"
get 'http://downloads.sourceforge.net/project/pupnp/files/pupnp/libUPnP 1.6.6/libupnp-1.6.6.tar.bz2'
DIRU="$(pwd)"
get_dj() { mv libupnp libupn_org; ln -s "../${DIRU##*/}" libupnp; patch -p1 -i "$DIRP/djmount.patch"; }
get 'http://downloads.sourceforge.net/project/djmount/files/djmount/0.71/djmount-0.71.tar.gz' run=get_dj

# config, build, install
Configure() { FUSE_CFLAGS="-I$DIRF/include -D_FILE_OFFSET_BITS=64" \
	FUSE_LIBS="-L$DIRF/lib/.libs -lfuse -pthread -ldl" \
	./configure "$@" --disable-debug --disable-charset; }
s=''; [ "$PLATFORM" != S7 ] && s='CONF+=static'
build $s inst='root src_dst djmount/djmount usr/bin/' "$@"; # always respect cmd line params
