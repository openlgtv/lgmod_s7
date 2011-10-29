#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)
note dfb

# download, extract
get_sc() { sed -i -e 's/_host_alias=""/_host_alias='"$CC_PREF/" configure; }
get 'http://kent.dl.sourceforge.net/project/scummvm/scummvm/1.3.1/scummvm-1.3.1.tar.bz2' run=get_sc

# config, build, install
Configure() { CPPFLAGS="$CPPFLAGS $SDL_CFLAGS" LIBS="$LIBS $SDL_LIBS" ./configure --disable-debug --enable-release "$@"; }
build CONF+='dfb zlib png SDL' inst='ext dest usr/local/bin/ scummvm' "$@"; # always respect cmd line params
#inst='ext make install'; # this does not strip it
