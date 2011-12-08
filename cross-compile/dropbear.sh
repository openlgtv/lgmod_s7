#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)
[ "$PLATFORM" != S7 ] || note zlib

# download, extract
get 'http://downloads.sourceforge.net/project/libpng/zlib/1.2.3/zlib-1.2.3.tar.gz'
DIRZ="$(pwd)"
get_db() { sed -i -e 's!^\(#define \(ENABLE_X11FWD\|INETD_MODE\|DROPBEAR_TWOFISH\|DROPBEAR_MD5_HMAC\|DO_HOST_LOOKUP\|DO_MOTD\)\)!//\1!' options.h; }
get 'http://matt.ucc.asn.au/dropbear/releases/dropbear-0.53.1.tar.gz' run=get_db

# config, build, install
Make() { make PROGRAMS="scp dbclient dropbear dropbearkey dropbearconvert"; }
if [ "$PLATFORM" != S7 ]; then Configure() { ./configure "$@" --disable-zlib; }
else Configure() { CFLAGS="$CFLAGS -I$DIRZ"; LIBS="$LIBS -L$ZLIB_DIR -lz" ./configure "$@"; }
	#Make() { make MULTI=1 PROGRAMS="dbclient dropbear dropbearkey scp dropbearconvert"; }
	#Install() { INST_dest "$1/usr/bin/" dropbearmulti; }
fi; build CONF+=size inst='root dest usr/bin/ scp dbclient dropbear dropbearkey dropbearconvert' "$@"; # always respect cmd line params

# with current options
#-rwxr-xr-x 1 rcon rcon  37800 Oct 26 12:25 usr/bin/scp
#-rwxr-xr-x 1 rcon rcon 212448 Oct 26 12:25 usr/bin/dbclient
#-rwxr-xr-x 1 rcon rcon 216384 Oct 26 12:25 usr/bin/dropbear
#-rwxr-xr-x 1 rcon rcon  85752 Oct 26 12:25 usr/bin/dropbearkey
#-rwxr-xr-x 1 rcon rcon  84916 Oct 26 12:25 usr/bin/dropbearconvert
# if multi
#-rwxr-xr-x 1 rcon rcon 301280 Oct 26 15:46 usr/bin/dropbearmulti
# debian-mipsel binaries
#usr/bin/scp is not from dropbear package
#-rwxr-xr-x 1 rcon rcon 221152 Oct 26 10:21 usr/bin/dbclient
#-rwxr-xr-x 1 rcon rcon 229364 Oct 26 10:21 usr/bin/dropbear
#-rwxr-xr-x 1 rcon rcon  90084 Oct 26 10:21 usr/bin/dropbearkey
#-rwxr-xr-x 1 rcon rcon  85152 Oct 26 10:21 usr/bin/dropbearconvert
