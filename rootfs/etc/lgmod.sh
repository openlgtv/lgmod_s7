#!/bin/sh
#
# LGMOD version ver=
# http://openlgtv.org.ru
# Copyright 2009 Vuk
# Copyright 2010 Arno1
#
CFG_DIR="/mnt/lg/user/lgmod"
MODULES_DIR=/lib/modules
NETCONFIG="$CFG_DIR/network"
HTTPD_CONF="$CFG_DIR/httpd.conf"
A_SH="$CFG_DIR/auto_start.sh"
S_SH="$CFG_DIR/auto_stop.sh"
P_SH="$CFG_DIR/patch.sh"

# Init USB - only if needed
mount | grep Drive1 > /dev/null ||
	echo 1 > /proc/usercalls

# Wait until USB drive is mounted
for k in 0 1 2 3 4; do
	mount | grep Drive1 > /dev/null && break
	sleep 1; done

# Reset all LGMOD configs to default if special file is present on USB drive
if [ -e /mnt/usb1/Drive1/lgmod_reset_config ]; then
    cp -R $CFG_DIR /mnt/usb1/Drive1
    rm -rf $CFG_DIR
    mv /mnt/usb1/Drive1/lgmod_reset_config /mnt/usb1/Drive1/lgmod_reset_config_used
    sync
    echo "LGMOD: Config folder is copied to the USB drive and deleted. Rebooting..."
    reboot
fi

# Create directory for LGMOD configuration files if not exists
if [ ! -e $CFG_DIR ]; then
    mkdir $CFG_DIR
fi

# Copy network config file from USB drive if exists to the LGMOD config folder
if [ -e /mnt/usb1/Drive1/network ]; then
    cp /mnt/usb1/Drive1/network $NETCONFIG
    dos2unix $NETCONFIG
    mv /mnt/usb1/Drive1/network /mnt/usb1/Drive1/network_used
    echo "LGMOD: Network config file is copied from the USB drive to the LGMOD config folder"
fi

# Copy Web UI configuration file from USB drive if exists to the LGMOD config folder
if [ -e /mnt/usb1/Drive1/httpd.conf ]; then
    cp /mnt/usb1/Drive1/httpd.conf $HTTPD_CONF
    dos2unix $HTTPD_CONF
    mv /mnt/usb1/Drive1/httpd.conf /mnt/usb1/Drive1/httpd.conf_used
    echo "LGMOD: Web UI config is copied from USB drive to the LGMOD config folder"
fi

# Create default Web UI config file with default user and password
if [ ! -e $HTTPD_CONF ]; then
    echo "A:*"  > $HTTPD_CONF
    echo "/cgi-bin:admin:lgadmin"  >> $HTTPD_CONF
fi

# Copy autostart script from USB drive if exist
if [ -e /mnt/usb1/Drive1/auto_start.sh ]; then
    cp /mnt/usb1/Drive1/auto_start.sh $A_SH
    dos2unix $A_SH
    chmod +x $A_SH
    mv /mnt/usb1/Drive1/auto_start.sh /mnt/usb1/Drive1/auto_start.sh_used
    echo "LGMOD: Autostart script is copied from USB drive to the LGMOD config folder"
fi

# Create default autostart script
if [ ! -e $A_SH ]; then
    echo "#!/bin/sh" > $A_SH
    echo "# Autostart script launched at the end of LGMOD boot" >> $A_SH
    echo "# at that time you have USB and network working normally" >> $A_SH
    echo "# as well as RELEASE running" >> $A_SH
    echo "" >> $A_SH
    echo "# Luca's hack to release caches every second (uncomment if you use NFS shares)" >> $A_SH
    echo "#while true ; do echo 3 > /proc/sys/vm/drop_caches ; sleep 10 ; done &" >> $A_SH
    echo "" >> $A_SH
    chmod +x $A_SH
fi    

# Create default autostop script
if [ ! -e $S_SH ]; then
    echo "#!/bin/sh" > $S_SH
    chmod +x $S_SH
fi    

# Copy patch script from USB drive if exists
if [ -e /mnt/usb1/Drive1/patch.sh ]; then
    cp /mnt/usb1/Drive1/patch.sh $P_SH
    dos2unix $P_SH
    chmod +x $P_SH
    mv /mnt/usb1/Drive1/patch.sh /mnt/usb1/Drive1/patch.sh_used
    sync
    echo "LGMOD: Copied patch script from USB drive. Rebooting..."
    reboot
fi
sync

# Configuring network
echo "LGMOD: Setting network loopback"
ifconfig lo 127.0.0.1

if [ ! -e $NETCONFIG -o -e $CFG_DIR/dhcp ]; then
    echo "LGMOD: Configuring network via DHCP..."
    udhcpc -t3 -A5 -S
else
    echo "LGMOD: Configuring network via network config file"
    IP=`awk '{ print $1}' $NETCONFIG`
    MASK=`awk '{ print $2}' $NETCONFIG`
    GW=`awk '{ print $3}' $NETCONFIG`
    ifconfig eth0 $IP netmask $MASK
    route add default gw $GW eth0
    [ -e $CFG_DIR/resolv.conf ] &&
        cat $CFG_DIR/resolv.conf >/tmp/resolv.conf
fi

# After network is configured, network services can be started
# Launch telnet server
if [ -e $CFG_DIR/telnet ] && ! pgrep telnetd > /dev/null; then
    insmod "$MODULES_DIR/pty.ko"
    /usr/sbin/telnetd -S -l /etc/auth.sh
fi

# Launch Web UI
pgrep httpd > /dev/null ||
	/usr/sbin/httpd -c $HTTPD_CONF -h /var/www

# Launch NTP client
[ -e $CFG_DIR/ntp ] && ntpd -q -p `cat $CFG_DIR/ntp`

[ -z "$1" ] && /etc/init.d/lgmod mount

# Launch FTP server
[ -e $CFG_DIR/ftp ] && tcpsvd -E 0.0.0.0 21 ftpd -S -w `cat $CFG_DIR/ftp` &

# Launch UPnP client
if [ -e $CFG_DIR/upnp ]; then
    insmod "$MODULES_DIR/fuse.ko"
    /usr/bin/djmount -f -o kernel_cache `cat $CFG_DIR/upnp` &
fi
