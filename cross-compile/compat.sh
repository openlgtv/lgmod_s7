#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)

# download, extract
get_cw() { patch -p1 -i "$CONF_DIR/compat_build.patch"; }
get 'http://www.orbit-lab.org/kernel/compat-wireless-3.0-stable/v3.0/compat-wireless-3.0-2.tar.bz2' run=get_cw

# config, build, install
export KLIB="$K_DIR"; export KLIB_BUILD="$K_DIR"
Install() { for i in `find . -type f | grep ko$`; do INST_dest "$1/lib/modules/compat/" "$i"; done; }
build noconf inst='ext dest ' "$@"; # always respect cmd line params
