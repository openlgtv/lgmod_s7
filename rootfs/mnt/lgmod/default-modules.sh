#!/bin/sh
# Core network modules
insmod mii.ko
insmod usbnet.ko
# Pegasus network chipset module
insmod pegasus.ko
# Asix network chipset module
insmod asix.ko
# MCS7830 network chipset module
insmod mcs7830.ko
# DM9601 network chipset module
insmod dm9601.ko

# CDROM filesystem modules
#insmod cdrom.ko
#insmod isofs.ko
#insmod sr_mod.ko
# CIFS/Samba filesystem module with max buffer size 127Kbyte
#insmod cifs.ko CIFSMaxBufSize=130048
insmod cifs.ko
# EXT2 filesystem module
#insmod ext2.ko
# Journaling layer for EXT3 filesystem
#insmod jbd.ko
# EXT3 filesystem module
#insmod ext3.ko
# NFS filesystem modules
#insmod sunrpc.ko
#insmod lockd.ko
#insmod nfs.ko

# USB2Serial and mini_fo modules
#insmod usbserial.ko
#insmod pl2303.ko
#insmod mini_fo.ko
