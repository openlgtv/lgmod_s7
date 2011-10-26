#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)
note dfb

# download, extract
get 'http://directfb.org/downloads/Libs/LiTE-0.8.10.tar.gz'
DIRL="$(pwd)"
get 'http://directfb.org/downloads/Programs/DFBTerm-0.8.15.tar.gz'

# config, build, install
Configure() { LITE_CFLAGS+=" -I$DIRL -DLITEFONTDIR="'\"${datarootdir}/fonts/truetype\"' \
	LITE_LIBS+=" -L$DIRL/lite/.libs -llite" ./configure "$@"; }
build CONF+=dfb inst='ext make install' "$@"; # always respect cmd line params
