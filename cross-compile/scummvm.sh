#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)
note dfb
echo 'Help: download extract and run: scummvm -enull lure'
echo 'Help: http://downloads.sourceforge.net/project/scummvm/scummvm/extras/Lure%20of%20the%20Temptress/lure-1.1.zip'
echo 'Help: https://raw.github.com/scummvm/scummvm/v1.3.1/dists/engine-data/lure.dat'
#?http://downloads.sourceforge.net/project/scummvm/scummvm/demos/agos/elvira1-dos-ni-demo-en.zip

# download, extract
get_sc() { sed -i -e 's/_host_alias=""/_host_alias='"$CC_PREF/" configure; }
get 'http://downloads.sourceforge.net/project/scummvm/scummvm/1.3.1/scummvm-1.3.1.tar.bz2' run=get_sc

# config, build, install
Configure() { CPPFLAGS="$CPPFLAGS $SDL_CFLAGS" LIBS="$LIBS $SDL_LIBS" ./configure --disable-debug --enable-release "$@"; }
build CONF+='dfb zlib png SDL' inst='ext dest usr/local/bin/ scummvm' "$@"; # always respect cmd line params
#inst='ext make install'; # this does not strip it
