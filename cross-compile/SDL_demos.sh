#!/bin/bash
# Source code released under GPL License
# cross-compile scripts for Saturn6/Saturn7 by mmm4m5m

. "${0%/*}/.functions.sh"; # first line (do not pass cmd line params)
note dfb

(

# download, extract
get 'http://www.libsdl.org/projects/optimum/src/optimum-1.0.tar.gz'

# config, build, install
Configure() { ./configure "$@" && sed -i -e 's/difference\|flares\|flashouillis\|galaxy\|infplane//g' Makefile; }
build CONF+='gcc dfb SDL' inst='ext dest usr/local/bin/ dawafire/dawafire bump/bump blob/blob' "$@"; # always respect cmd line params
#failed: tunnel/tunnel rotozoom/rotozoom ftunnel/ftunnel flamme/flamme bitore/bitore

); echo; echo; (

# download, extract
get 'http://www.libsdl.org/projects/xflame/src/xflame-1.0.tar.gz'

# config, build, install
build CONF+='gcc dfb SDL' inst='ext dest usr/local/bin/ xflame' "$@"; # always respect cmd line params

); echo; echo; (

# download, extract
get 'http://www.libsdl.org/projects/screenart/src/screenart-1.1.tar.gz'

# config, build, install
build CONF+='gcc dfb SDL' inst='ext dest usr/local/bin/ screenart' "$@"; # always respect cmd line params

); echo; echo; (

# download, extract
get 'http://www.libsdl.org/projects/plasma/src/plasma-1.0.tar.gz'

# config, build, install
build CONF+='gcc dfb SDL' inst='ext dest usr/local/bin/ plasma' "$@"; # always respect cmd line params

); echo; echo; (

# download, extract
get 'http://www.libsdl.org/projects/sierp/src/sierp-1.0.tar.gz'

# config, build, install
build CONF+='gcc dfb SDL' inst='ext dest usr/local/bin/ sierp' "$@"; # always respect cmd line params

); echo; echo; (

# download, extract
get 'http://www.libsdl.org/projects/warp/src/warp-1.1.tar.gz'

# config, build, install
build CONF+='gcc dfb SDL' noinstall inst='ext dest usr/local/bin/ warp' "$@"; # always respect cmd line params

); echo; echo; (

# download, extract
get 'http://www.libsdl.org/projects/stars/src/stars-1.0.tar.gz'

# config, build, install
build CONF+='gcc dfb SDL' noinstall inst='ext dest usr/local/bin/ stars' "$@"; # always respect cmd line params

); echo; echo; (

# download, extract
get 'http://www.libsdl.org/projects/water/src/water-1.0.tar.gz'

# config, build, install
build CONF+='gcc dfb SDL' noinstall inst='ext dest usr/local/bin/ water' "$@"; # always respect cmd line params

); echo; echo; (

# download, extract
get 'http://www.libsdl.org/projects/newvox/src/newvox-1.0.tar.gz'

# config, build, install
build CONF+='gcc dfb SDL' noinstall inst='ext dest usr/local/bin/ newvox' "$@"; # always respect cmd line params

); echo; echo; (

# download, extract
get 'http://www.libsdl.org/projects/fire/src/fire-1.0.tar.gz'

# config, build, install
build CONF+='gcc dfb SDL' noinstall inst='ext dest usr/local/bin/ fire' "$@"; # always respect cmd line params



); echo; echo; (

# download, extract
#?get_ptc() { sed -i -e 's/^\(.*.*eval echo configure:.* test -s conftest..ac_exeext. .. ...conftest. exit. ...dev.null\)$/if true; #\1/' configure; }
get 'http://www.libsdl.org/projects/PTC/src/PTC-demos-1.0.tar.gz' run=get_ptc

# config, build, install
Configure() { CXX="$CC_PREF-c++" ./configure "$@"; }
build CONF+='gcc dfb SDL' noinstall inst='ext dest usr/local/bin/ Fire Tunnel' "$@"; # always respect cmd line params

); echo; echo; (

# download, extract
get 'http://sourceforge.net/projects/libpng/zlib/1.2.3/zlib-1.2.3.tar.gz'
DIRZ="$(pwd)"
get_qr() { sed -i -e 's/\(register\)\( tmp \)/\1 int\2/' -e 's/\(static\)\( color \)/\1 int\2/' 3d.cpp;
	sed -i -e 's/\(const\|static\)\( N_FIG=\| phase \| scale_timer \| color_offset \)/\1 int\2/' abstract.cpp;
	sed -i -e 's/\(const\|static\)\( ANGLE_TIME \| offset=\)/\1 int\2/' begin.cpp;
	sed -i -e 's/\(const\|static\)\( old_order \| offset \)/\1 int\2/' cars.cpp;
	sed -i -e 's/\(const\|static\)\( first \| skip_order \)/\1 int\2/' crash.cpp; }
get 'http://www.libsdl.org/projects/qrash/src/qrash-1.0.tar.gz'; #run=get_qr

# config, build, install
Configure() { CXX="$CC_PREF-c++" CPPFLAGS="$CFLAGS -I$DIRZ -fpermissive" ./configure "$@"; }
build CONF+='gcc dfb SDL' noinstall inst='ext dest usr/local/bin/ qrash' "$@"; # always respect cmd line params

); echo; echo; (

# download, extract
get_hel() { #?sed -i -e 's/^\(.*configure:1432\)/if true; #\1/' configure
	sed -i -e 's/\(setDrawLineShadow\|setDrawLineNoShadow\|setDrawLineNoTexture\)/void \1/' 3d.h
	sed -i -e 's/^inline \(FacedObject::\(setDrawLineShadow\|setDrawLineNoShadow\|setDrawLineNoTexture\)\)/inline void \1/' \
		-e 's/\(register tmp \)/register int tmp /' -e 's/\(#include "parts.h"\)/\1\n/#include "string.h"' 3d.cpp
	sed -i -e 's/\(register \(mask\|stepx\) \)/register int \2 /' image.cpp; }
get 'http://www.libsdl.org/projects/HElliZER/src/HElliZER-1.0.tar.gz'; #run=get_hel

# config, build, install
Configure() { CXX="$CC_PREF-c++" CPPFLAGS="$CFLAGS -fpermissive" ./configure "$@"; }
build CONF+='gcc dfb SDL' noinstall inst='ext dest usr/local/bin/ HElliZER' "$@"; # always respect cmd line params



); echo; echo; (

# download, extract
get 'http://www.libsdl.org/projects/cmouse/src/cmouse-0.1.tar.gz' dir=Mouse

# config, build, install
Configure() { make; }
build nomake CONF+='gcc dfb SDL' noinstall inst='ext dest usr/local/bin/ cmouse' "$@"; # always respect cmd line params

); echo; echo; (

# download, extract
get 'http://www.libsdl.org/projects/bump/src/bump.zip' act=zip dir=SDL_bump

# config, build, install
Configure() { cmd="$CC $SDL_CFLAGS $SDL_LIBS";  }
Make() { $cmd -o SDL_bump main.cpp -lstdc++ -DLINUX_COMPIL; }
build noclean CONF+='gcc dfb sdl' noinstall inst='ext dest usr/local/bin/ SDL_bump' "$@"; # always respect cmd line params

)



false && {
	# download, extract
	get 'http://www.libsdl.org/projects/flxplay/src/flxplay-0.2.tar.gz'

	# config, build, install
	Configure() { make; }
	build CONF+='gcc dfb SDL' noinstall inst='ext dest usr/local/bin/ ?' "$@"; # always respect cmd line params
	#??? flxplay.c:93: error: lvalue required as left operand of assignment
}
