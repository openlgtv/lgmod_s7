#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

### Example
#. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)
#
## download, extract
#after_get() { ... }; # do something once, after extract - apply patches
#get 'http://links.twibright.com/download/links-2.3.tar.gz' run=after_get
#
## config, build, install
#Configure() { ./configure param=value; }; # if custom/more/special parameters are required
#build CONF+='gcc dfb' inst='ext install-exec' "$@"; # always respect cmd line params

### Howto - check the existing examples in cross-compile scripts
### Check expected/possible parameters in 'get' and 'build' functions (below)
### You can add custom 'Configure', 'Make', 'Install' functions
### For 'inst' parameter - check inside 'build' function and all 'INST_*' functions

### './configure' parameters are collected from few 'CONF_*' functions
### These are called one by one. At the end, './configure' is called
### This chain is defined with 'CONF' parameter, like: 'CONF+='gcc dfb'
### To test and see it - you could add 'Configure' function and 'echo $@'

### 'inst' parameters is ignored if 'Install' function exists
### Few keywords are recognized in 'inst': root ext make dest src_dst strip
### Example: inst='ext make install' will call INST_make function
###   It is equivalent to: make DEST_DIR=$INST_EXT install


# platform
platform() {
	PLATFORM=S7; #PLATFORM=''
	local ex=0; # shift<100 or err>100
	[ "$1" = S6 ] && { ex=$(( ex+1 )); PLATFORM=S6; }
	[ "$1" = S7 ] && { ex=$(( ex+1 )); PLATFORM=S7; }
	[ -z "$PLATFORM" ] && { echo "ERROR: $1=<S6|S7>"; exit 100; }
	SUFFIX="-$PLATFORM"
	[ "$PLATFORM" = S7 ] && SUFFIX=''; # TODO rootfs-S7
	return $ex
}


# paths
CD() { cd "$1" && return; echo "ERROR: $d not found."; exit 1; }
paths() {
	CD "${0%/*}" || exit $?; CONF_DIR=$(pwd)
	CD .. || exit $?; INST_DIR=$(pwd)/rootfs$SUFFIX
	CD .. || exit $?; INST_EXT=$(pwd)/extroot$SUFFIX; INST_TST=$(pwd)/extroot-tst

	CD .. || exit $?; # now PWD=lgmod_s7/.. ('lgmod_s7' from svn)
	SRC_DIR="$(pwd)/sources"
	DFB_DIR="$SRC_DIR/DirectFB-LG-usr_local_lib"; ZLIB_DIR="$DFB_DIR"; PNG_DIR="$DFB_DIR"
		CC_ZLIB="$SRC_DIR/zlib-1.2.3"; CC_PNG="$SRC_DIR/libpng-1.2.29"
	SDL_DIR="$SRC_DIR/SDL-1.2.14"

	if [ "$PLATFORM" = S7 ]; then
		CC_dir=Saturn7/cross-compiler; CC_DIR="$(pwd)/$CC_dir"; CC_PREF=mipsel-linux
		K_DIR="$(pwd)/Saturn7/GP2_M_CO_FI_2010/kernel_src/kernel/linux-2.6.26-saturn7"
		CC_DFB="$(pwd)/Saturn7/GP2_MSTAR/directFB"
	else
		CC_dir=cross-compiler-mipsel; CC_DIR="$(pwd)/$CC_dir"; CC_PREF=mipsel
		# TODO S6
		#CC_dir=S6/mipsel-gcc-4.1.2-uclibc-0.9.28.3-mips32; CC_DIR="$(pwd)/$CC_dir"; CC_PREF=mipsel-linux
		#K_DIR="$(pwd)/S6/GP1_M_CO_FI_2010/kernel_src/kernel/linux-2.6.26-saturn6"
		#CC_DFB="$(pwd)/S6/GP1_MSTAR/directFB"
	fi
	CC_BIN="$CC_DIR/bin"
	CC_STRIP="$CC_BIN/$CC_PREF-strip"
}


# notes/help/hints/tips
note() {
	if [ "$1" = dfb ]; then
		echo 'Note: Copy files from LG TV /usr/local/lib to:'
		echo "	$DFB_DIR"
	elif [ "$1" = zlib ]; then
		echo 'Note: Copy libz.so* from LG TV /usr/local/lib to:'
		echo "	$ZLIB_DIR"
	fi
}

# download and extract
get() {
	local CC=''; [ "$1" = CC ] && { CC=1; shift; }
	local i d r url="$1"; local tar="${url##*/}" act='' dir='' run=''; shift
	for i in "$@"; do
		[ "${i#tar=}" != "$i" ] && tar="${i#tar=}"
		[ "${i#act=}" != "$i" ] && act="${i#act=}"
		[ "${i#dir=}" != "$i" ] && dir="${i#dir=}"
		[ "${i#run=}" != "$i" ] && run="${i#run=}"
	done

	if [ -z "$act" ]; then
		d=''
		if   [ "$tar" != "${tar%.tar.gz}" ];  then act=.tar.gz;  d="${tar%.tar.gz}"
		elif [ "$tar" != "${tar%.tgz}" ];     then act=.tgz;     d="${tar%.tgz}"
		elif [ "$tar" != "${tar%.tar.bz2}" ]; then act=.tar.bz2; d="${tar%.tar.bz2}"
		elif [ "$tar" != "${tar%.zip}"    ];  then act=.zip;     d="${tar%.zip}"
		fi
		[ -z "$dir" ] && dir="$d"
	elif [ -z "$dir" ]; then
		if [ "$act" = svn ]; then dir="$tar"
		fi
	fi
	[ -z "$dir" ] && dir="${tar%%.*}"

	[ -n "$CC" ] || CD "$SRC_DIR" || exit $?
	if [ ! -d "$dir" ]; then
		read -n1 -p "Press Y to download/extract/checkout $tar ... " r; echo; [ "$r" = Y ] || exit 90
		if [ "$act" = svn ]; then svn co "$tar" "$dir" || exit $?
		else [ -f "$tar" ] || { wget "$url" -O - > "$tar" || exit $?; }; fi

		if   [ "$act" = .tar.gz ];  then tar -xzf "$tar" || exit $?
		elif [ "$act" = .tar.bz2 ]; then tar -xjf "$tar" || exit $?
		elif [ "$act" = .zip ];     then unzip "$tar" || exit $?
		elif [ "$act" = zip ];     then unzip "$tar" -d "$dir" || exit $?
		elif [ "$act" = svn ];     then :;
		else echo "ERROR: Unknown 'get' action: $act"; exit 2
		fi

		CD "$dir" || exit $?
		[ -n "$run" ] && $run
		exit 99
	else CD "$dir" || exit $?; fi
}


# config, build, install
CONF_SDL() {
	local d="$CONF_DIR/sdl-config"
	SDL_CONFIG="$d" PATH="$CONF_DIR:$PATH" CONF_sdl "$@"
}
CONF_sdl() {
	SDL_CFLAGS="$SDL_CFLAGS -I$SDL_DIR/include" SDL_LIBS="$SDL_LIBS -L$SDL_DIR/build/.libs -lSDL $DIRECTFB_LIBS" \
		CONFIGURE "$@"
}
CONF_DFB() {
	# old trick './configure' (distclean required by 'tempfile' always new file name)
	#d=`tempfile`; chmod +x "$d"; { echo '#!/bin/sh'; echo '[ "$1" = "--version" ] && echo 1.2.7'; } > "$d"
	# new trick
	local d="$CONF_DIR/directfb-config"
	DIRECTFBCONFIG="$d" DIRECTFB_CONFIG="$d" PATH="$CONF_DIR:$PATH" \
		CONF_dfb "$@"
	# old trick './configure' (cleanup)
	#rm -f $DIRECTFBCONFIG
}
CONF_dfb() {
	DIRECTFB_CFLAGS="$DIRECTFB_CFLAGS -I$CC_DFB/include -I$CC_DFB/lib -D_REENTRANT" \
	DIRECTFB_LIBS="$DIRECTFB_LIBS -L$DFB_DIR -ldirectfb -lfusion -ldirect -lpthread -lz" \
		CONFIGURE "$@"
}
CONF_png() {
	PNG_CFLAGS="$PNG_CFLAGS -I$CC_PNG $ZLIB_CFLAGS" PNG_LIBS="$PNG_LIBS -L$PNG_DIR -lpng $ZLIB_LIBS" \
		CONFIGURE "$@"
}
CONF_zlib() {
	ZLIB_CFLAGS="$ZLIB_CFLAGS -I$CC_ZLIB" ZLIB_LIBS="$ZLIB_LIBS -L$ZLIB_DIR -lz" \
		CONFIGURE "$@"
}
CONF_gcc() {
	CC=$CC_PREF-gcc CONFIGURE "$@"
}
CONF_static() {
	CFLAGS="$CFLAGS -static" LDFLAGS="$LDFLAGS -all-static" CONFIGURE "$@"
}
CONF_size() {
	CFLAGS="$CFLAGS -Os -W -Wall" CONFIGURE "$@"
}
CONF_host() {
	CONFIGURE --host=$CC_PREF "$@"
}

CONFIGURE() {
	if [ -z "$CONF" ]; then
		# CONF chain empty - call Configure or ./configure
		local t=`type -t Configure`
		if [ "$t" = 'function' ]; then
			Configure "$@"
		else
			./configure "$@"
		fi
	elif [ "$CONF" = "${CONF%% *}" ]; then
		# one function left in CONF chain
		CONF='' "CONF_${CONF%% *}" "$@"
	else
		# call first function from CONF chain
		CONF="${CONF#* }" "CONF_${CONF%% *}" "$@"
	fi
}

INST_one() {
	local src="$1" dst="$2"; [ "$dst" != "${dst%%/}" ] && dst="$dst${src##*/}"
	[ -d "$dst" ] && { dst="$dst/${src##*/}"; echo "Note: cp -ax $src $dst"; }
	mkdir -p "${dst%/*}" || exit $?
	cp -ax "$src" "$dst" || exit $?
	#"$CC_BIN/$CC_PREF-strip" --strip-unneeded "$dst"
	#file "$dst" && ls -l "$dst"
	CC_STRIP="$CC_STRIP" "$CONF_DIR/.strip" --strip-unneeded "$dst"
}
INST_dest() {
	local i dst="$1"; shift; for i in "$@"; do INST_one "$i" "$dst"; done
}
INST_src_dst() {
	local DST="$1"; INST_one "$2" "$DST/$3" || exit $?; shift 3
	[ $# = 0 ] ||
		if [ $# -gt 1 ]; then INST_src_dst "$DST" "$@"
		else echo "ERROR: No destination for source file: $1 ($pwd)"; exit 3; fi
}
INST_make() {
	make DESTDIR="$1" "$@"
}
INST_strip() {
	local dst="$1"; shift
	CC_STRIP="$CC_STRIP" INST_make "$dst" INSTALL="/usr/bin/install -c -s --strip-program $CONF_DIR/.strip" "$@"
}

build() {
	local t r bash='' help='' clean=1 distclean='' conf=1 make=1 install='' inst=''; CFG=''; modules=''; # not local
	CONF='host'; #size; #[ "$PLATFORM" != S7 ] && CONF="$CONF static"; # CONF chain
	for i in "$@"; do
		[ "$i" = bash ]    && bash=1;    [ "$i" = nobash ]    && bash=''
		[ "$i" = help ]    && help=1;    [ "$i" = nohelp ]    && help=''
		[ "$i" = clean ]   && clean=1;   [ "$i" = noclean ]   && clean=''
		[ "$i" = distclean ] && distclean=1; [ "$i" = nodistclean ] && distclean=''
		[ "$i" = CFG ]     && CFG=1;     [ "$i" = NOCFG ]     && CFG=''
		[ "$i" = conf ]    && conf=1;    [ "$i" = noconf ]    && conf=''
		[ "$i" = make ]    && make=1;    [ "$i" = nomake ]    && make=''
		[ "$i" = modules ] && modules=1; [ "$i" = nomodules ] && modules=''
		[ "$i" = install ] && install=1; [ "$i" = noinstall ] && install=0
		[ "${i#inst=}" != "$i" ] && inst="${i#inst=}"
		[ "${i#CONF+=}" != "$i" ] && CONF="$CONF ${i#CONF+=}"
		[ "${i#CONF=}" != "$i" ] && CONF="${i#CONF=}"
	done

	[ -n "$bash" ] && { bash; exit 91; }
	[ -n "$help" ] && { ./configure --help; exit 92; }

	[ -n "$clean" ] && {
		t=`type -t Clean`
		if [ "$t" = 'function' ]; then Clean "$distclean"
		else make clean; [ -n "$distclean" ] && make distclean
		fi
	}

	[ -n "$conf" ] && { CONFIGURE || exit $?; }
	[ -n "$make" ] && {
		t=`type -t Make`
		if [ "$t" = 'function' ]; then Make || exit $?
		else make || exit $?
		fi
	}

	if [ "$install" != 0 ]; then
		if [ -z "$install" ]; then
			read -n1 -p "Press Y to install: $inst ... " r; echo
			[ "$r" = Y ] || return 1
		fi
		local t strip='' dst='' mode=''
		while true; do
			if   [ "${inst#strip }" != "$inst" ]; then strip=1; inst="${inst#strip }"
			elif [ "${inst#root }" != "$inst" ]; then dst="$INST_DIR"; inst="${inst#root }"
			elif [ "${inst#ext }" != "$inst" ];  then dst="$INST_EXT"; inst="${inst#ext }"
			elif [ "${inst#tst }" != "$inst" ];  then dst="$INST_TST"; inst="${inst#tst }"
			elif [ "${inst#make }" != "$inst" ]; then mode=make; inst="${inst#make }"
			elif [ "${inst#src_dst }" != "$inst" ]; then mode=src_dst; inst="${inst#src_dst }"
			elif [ "${inst#dest }" != "$inst" ]; then mode=dest; inst="${inst#dest }"
			else break; fi
		done
		t=`type -t Install`
		if   [ "$t" = 'function' ]; then Install "$dst" "$inst" || exit $?
		elif [ "$mode" = make ] && [ -z "$strip" ]; then INST_make "$dst" $inst || exit $?
		elif [ "$mode" = make ] && [ -n "$strip" ]; then INST_strip "$dst" $inst || exit $?
		elif [ "$mode" = src_dst ]; then INST_src_dst "$dst" $inst || exit $?
		elif [ "$mode" = dest ]; then INST_dest "$dst/${inst%% *}" ${inst#* } || exit $?
		else echo 'ERROR: Install method/function not defined.'; exit 4
		fi
	fi
}


# run once and 'shift' cmd line arguments (once)
if [ -z "$PLATFORM" ]; then
	platform "$@"; ex=$?
	[ $ex -lt 100 ] && shift $ex || exit $ex
	paths
	[ "$1" = CC ] && shift ||
		{ CD "$CC_BIN" || exit $?; }
	export PATH="$CC_BIN:$PATH"
	mkdir -p "$SRC_DIR" &&
		CD "$SRC_DIR" || exit $?

	# next steps: per script
	#note
	#get
	#build
fi
