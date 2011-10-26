#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)
note dfb

# download, extract
get 'http://directfb.org/downloads/Extras/DirectFB-examples-1.2.0.tar.gz'

# config, build, install
build CONF+=dfb inst='ext make install' "$@"; # always respect cmd line params
