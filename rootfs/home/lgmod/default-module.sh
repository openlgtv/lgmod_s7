#!/bin/sh
#modprobe mii; # ?
f=usbnet;  [ -d /sys/module/$f ] || modprobe $f; # Core network modules
f=pegasus; [ -d /sys/module/$f ] || modprobe $f; # Pegasus network chipset module
f=asix;    [ -d /sys/module/$f ] || modprobe $f; # Asix network chipset module
modprobe mcs7830; # MCS7830 network chipset module
modprobe dm9601;  # DM9601 network chipset module

# Ralink based wireless support (Rt2x00, Rt2500, Rt73)
modprobe rt2x00usb
#modprobe rt2500usb # It crashed with 148f:2573 !
modprobe rt73usb

# CIFS/Samba filesystem module with max buffer size 127Kbyte
#modprobe cifs; # CIFSMaxBufSize=130048

# Input modules
#modprobe input-core
#modprobe evdev
#modprobe uinput
#modprobe hid
#modprobe usbhid

# CDROM filesystem modules
#modprobe cdrom
#modprobe isofs
#modprobe sr_mod

# USB2Serial and mini_fo modules
#modprobe usbserial
#modprobe pl2303
#modprobe ftdi_sio
#modprobe mini_fo
