#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)
note dfb

# download, extract
#get_sdl() { ln -s . include/SDL; }
get 'http://www.libsdl.org/release/SDL-1.2.14.tar.gz'; #run=get_sdl

# config, build, install
build CONF+=DFB inst='ext make install-bin install-lib' "$@"; # always respect cmd line params
