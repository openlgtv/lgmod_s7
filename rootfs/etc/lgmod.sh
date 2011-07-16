#!/bin/sh
#
# LGMOD version 1.6.10
# http://openlgtv.org.ru
# Copyright 2009 Vuk
# Copyright 2010 Arno1
#
CFG_DIR="/mnt/lg/user/lgmod"
MODULES_DIR=/lib/modules
NETCONFIG="$CFG_DIR/network"
FS_MNT="$CFG_DIR/ndrvtab"
HTTPD_CONF="$CFG_DIR/httpd.conf"
A_SH="$CFG_DIR/auto_start.sh"
S_SH="$CFG_DIR/auto_stop.sh"
P_SH="$CFG_DIR/patch.sh"

# Init USB - only if needed
mount | grep Drive1 > /dev/null ||
	echo 1 > /proc/usercalls

# Wait until USB drive is mounted
k=0;
while ! mount | grep Drive1 > /dev/null; do
    sleep 1;
    k=$(($k+1))
    if [ $k -gt 30 ]; then break; fi
done;

# Reset all LGMOD configs to default if special file is present on USB drive
if [ -e /mnt/usb1/Drive1/lgmod_reset_config ]; then
    cp -R $CFG_DIR /mnt/usb1/Drive1
    rm -rf $CFG_DIR
    mv /mnt/usb1/Drive1/lgmod_reset_config /mnt/usb1/Drive1/lgmod_reset_config_used
    sync
    echo "LGMOD config folder is copied to the USB drive and deleted. Rebooting..."
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
    echo "Network config file is copied from the USB drive to the LGMOD config folder"
fi

# Copy Web UI configuration file from USB drive if exists to the LGMOD config folder
if [ -e /mnt/usb1/Drive1/httpd.conf ]; then
    cp /mnt/usb1/Drive1/httpd.conf $HTTPD_CONF
    dos2unix $HTTPD_CONF
    mv /mnt/usb1/Drive1/httpd.conf /mnt/usb1/Drive1/httpd.conf_used
    echo "Web UI config is copied from USB drive to the LGMOD config folder"
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
    mv /mnt/usb1/Drive1/auto_start.sh /mnt/usb1/Drive1/auto_start.sh_used
    echo "Autostart script is copied from USB drive to the LGMOD config folder"
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
    echo "#!/bin/sh" >> $S_SH
    chmod +x $S_SH
fi    

# Copy patch script from USB drive if exists
if [ -e /mnt/usb1/Drive1/patch.sh ]; then
    cp /mnt/usb1/Drive1/patch.sh $P_SH
    dos2unix $P_SH
    mv /mnt/usb1/Drive1/patch.sh /mnt/usb1/Drive1/patch.sh_used
    sync
    echo "Copied patch script from USB drive. Rebooting..."
    reboot
fi
sync

# Configuring network
echo "Setting network loopback"
ifconfig lo 127.0.0.1

if [ ! -e $NETCONFIG -o -e $CFG_DIR/dhcp ]; then
    echo "Configuring network via DHCP..."
    udhcpc
else
    echo "Configuring network via network config file"
    IP=`awk '{ print $1}' $NETCONFIG`
    MASK=`awk '{ print $2}' $NETCONFIG`
    GW=`awk '{ print $3}' $NETCONFIG`
    ifconfig eth0 $IP netmask $MASK
    route add default gw $GW eth0
    if [ -e $CFG_DIR/resolv.conf ]; then
	cat $CFG_DIR/resolv.conf >/tmp/resolv.conf
    fi
fi

# After network is configured, network services can be started
echo "Mounting shares..."
cat $FS_MNT | while read ndrv; do
automount=`echo $ndrv | awk -F# '{print $1}'`
fs_type=`echo $ndrv | awk -F# '{print $2}'`
src=`echo $ndrv | awk -F# '{print $3}'`
dst=`echo $ndrv | awk -F# '{print $4}'`
opt=`echo $ndrv | awk -F# '{print $5}'`
uname=`echo $ndrv | awk -F# '{print $6}'`
pass=`echo $ndrv | awk -F# '{print $7}'`

if [ "$automount" = "1" ]; then
    mnt_opt="-o noatime";
    [ "$uname" ] && mnt_opt="${mnt_opt},user=$uname,pass=$pass"
    [ "$opt" ] && mnt_opt="${mnt_opt},${opt}"
    mount -t $fs_type $mnt_opt $src $dst &
fi
done

# Launch NTP client
[ -e $CFG_DIR/ntp ] && ntpd -q -p `cat $CFG_DIR/ntp`

# Launch telnet server
if [ -e $CFG_DIR/telnet ]; then
  insmod "$MODULES_DIR/pty.ko"
  /usr/sbin/telnetd -l /etc/auth.sh
fi

# Launch FTP server
[ -e $CFG_DIR/ftp ] && tcpsvd -E 0.0.0.0 21 ftpd -w `cat $CFG_DIR/ftp` &

# Launch UPnP client
if [ -e $CFG_DIR/upnp ]; then
 insmod "$MODULES_DIR/fuse.ko"
 /usr/bin/djmount -f -o kernel_cache `cat $CFG_DIR/upnp` &
fi

# Launch Web UI
/usr/sbin/httpd -c $HTTPD_CONF -h /var/www

# Launch autostart script
$A_SH
