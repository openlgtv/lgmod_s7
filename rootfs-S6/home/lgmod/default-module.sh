#!/bin/sh
# Core network modules
modprobe mii
modprobe usbnet
# Pegasus network chipset module
modprobe pegasus
# Asix network chipset module
modprobe asix
# MCS7830 network chipset module
modprobe mcs7830
# DM9601 network chipset module
modprobe dm9601

# CIFS/Samba filesystem module with max buffer size 127Kbyte
#modprobe cifs; # CIFSMaxBufSize=130048

# CDROM filesystem modules
#modprobe cdrom
#modprobe isofs
#modprobe sr_mod

# USB2Serial and mini_fo modules
#modprobe usbserial
#modprobe pl2303
#modprobe ftdi_sio
#modprobe mini_fo
