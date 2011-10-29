#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)

# download, extract
get 'http://www.asix.com.tw/FrootAttach/driver/MCS780x_Linux_driver_v1.11.zip'

# config, build, install
Make() { make CROSS_COMPILE=$CC_PREF- KDIR="$K_DIR"; }
build noconf inst='root src_dst mcs7830.ko lib/modules/2.6.26/mcs7830-asix.ko' "$@"; # always respect cmd line params
