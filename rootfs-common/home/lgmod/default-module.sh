#!/bin/sh
[ -f /sbin/modprobe ] && modprobe=modprobe || modprobe=insmod
if [ ! -d /mnt/lg/lginit ]; then # S6 (or S7 with custom kernel)
	# Core network modules
	$modprobe mii.ko
	$modprobe usbnet.ko
	# Pegasus network chipset module
	$modprobe pegasus.ko
	# Asix network chipset module
	$modprobe asix.ko
fi
# MCS7830 network chipset module
$modprobe mcs7830.ko
#$modprobe mcs7830-lprot.ko
# DM9601 network chipset module
#$modprobe dm9601-2626.ko
$modprobe dm9601.ko

# Ralink based wireless support (Rt2x00, Rt2500, Rt73)
$modprobe rt2x00usb.ko
#$modprobe rt2500usb.ko # It crashed with 148f:2573 !
$modprobe rt73usb.ko

# CIFS/Samba filesystem module with max buffer size 127Kbyte
#$modprobe cifs.ko CIFSMaxBufSize=130048
$modprobe cifs.ko
# NFS filesystem modules
#$modprobe sunrpc.ko
#$modprobe lockd.ko
#$modprobe nfs.ko

# EXT2 filesystem module
#$modprobe ext2.ko
# Journaling layer for EXT3 filesystem
#$modprobe jbd.ko
# EXT3 filesystem module
#$modprobe ext3.ko

# CDROM filesystem modules
#$modprobe cdrom.ko
#$modprobe isofs.ko
#$modprobe sr_mod.ko

# USB2Serial and mini_fo modules
#$modprobe usbserial.ko
#$modprobe pl2303.ko
#$modprobe ftdi_sio.ko
#$modprobe mini_fo.ko
