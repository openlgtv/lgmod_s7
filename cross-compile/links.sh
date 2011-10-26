#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m, djpety

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)
note dfb

# download, extract
get 'http://sourceforge.net/projects/libpng/zlib/1.2.3/zlib-1.2.3.tar.gz'
DIRZ="$(pwd)"
get 'http://sourceforge.net/projects/libpng/libpng12/older-releases/1.2.29/libpng-1.2.29.tar.gz'
DIRP="$(pwd)"
get_jpeg() { build noclean CONF+=gcc nomake noinstall; }; # run ./configure once for jconfig.h
get 'http://sourceforge.net/projects/libjpeg/libjpeg/6b/jpegsrc.v6b.tar.gz' dir=jpeg-6b run=get_jpeg
DIRJ="$(pwd)"
get 'http://links.twibright.com/download/links-2.3.tar.gz'

# config, build, install
Configure() { CPPFLAGS+=" -I$DIRZ -I$DIRP -I$DIRJ" LIBS+=" -L$DFB_DIR -lz -lpng -ljpeg" \
	./configure "$@" --enable-graphics; }
build CONF+='gcc DFB' inst='ext strip make install-exec' "$@"; # always respect cmd line params
