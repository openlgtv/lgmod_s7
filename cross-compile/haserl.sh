#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)

# download, extract
get 'http://downloads.sourceforge.net/project/haserl/files/haserl-0.9.29.tar.gz'

# config, build, install
Configure() { ./configure "$@" --disable-luashell --disable-bash-extensions; }
build inst='root src_dst src/haserl usr/bin/' "$@"; # always respect cmd line params
