#!/bin/bash

CC_DIR="${0%/*}/../../../cross-compiler-mipsel/bin"
[ -d "${0%/*}" ] && [ -d "$CC_DIR" ] ||
	{ echo "ERROR: $CC_DIR not found."; exit 1; }
cd "${0%/*}"
echo 'Note: Busybox Settings->Build Options->Cross Compiler prefix'
echo "	$CC_DIR/mipsel-"

export PATH="$CC_DIR:$PATH"

if [ "$1" = noauto ]; then
	echo make menuconfig
	echo make 
	echo make CONFIG_PREFIX=../rootfs install
	#echo svn revert ../rootfs/bin/ps
	bash

elif [ "$1" = installonly ]; then
	make CONFIG_PREFIX=../rootfs install
	#svn revert ../rootfs/bin/ps

elif [ "$1" = noinstall ]; then
	make menuconfig
	make 
	echo make CONFIG_PREFIX=../rootfs install
	#echo svn revert ../rootfs/bin/ps

else
	make menuconfig
	make 
	make CONFIG_PREFIX=../rootfs install
	#svn revert ../rootfs/bin/ps

fi
