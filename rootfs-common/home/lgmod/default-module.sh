#!/bin/sh
[ -d /mnt/lg/lginit ] || $MODPROBE mii.ko; # S6 (or S7 with custom kernel)
f=usbnet;  [ -d /sys/module/$f ] || $MODPROBE $f.ko; # Core network modules
f=pegasus; [ -d /sys/module/$f ] || $MODPROBE $f.ko; # Pegasus network chipset module
f=asix;    [ -d /sys/module/$f ] || $MODPROBE $f.ko; # Asix network chipset module
$MODPROBE mcs7830.ko; # MCS7830 network chipset module
$MODPROBE dm9601.ko;  # DM9601 network chipset module

# Ralink based wireless support (Rt2x00, Rt2500, Rt73)
$MODPROBE rt2x00usb.ko
#$MODPROBE rt2500usb.ko # It crashed with 148f:2573 !
$MODPROBE rt73usb.ko

# CIFS/Samba filesystem module with max buffer size 127Kbyte
#$MODPROBE cifs.ko; # CIFSMaxBufSize=130048
# NFS filesystem modules
#$MODPROBE sunrpc.ko
#$MODPROBE lockd.ko
#$MODPROBE nfs.ko

# EXT2 filesystem module
#$MODPROBE ext2.ko
# EXT3 filesystem modules
#$MODPROBE jbd.ko
#$MODPROBE ext3.ko

# CDROM filesystem modules
#$MODPROBE cdrom.ko
#$MODPROBE isofs.ko
#$MODPROBE sr_mod.ko

# USB2Serial and mini_fo modules
#$MODPROBE usbserial.ko
#$MODPROBE pl2303.ko
#$MODPROBE ftdi_sio.ko
#$MODPROBE mini_fo.ko
