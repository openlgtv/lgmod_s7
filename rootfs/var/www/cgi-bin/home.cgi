#!/usr/bin/haserl
content-type: text/html

<? /usr/bin/haserl /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / HOME</p><div class="pagebody">

<div class="post"><div class="posttext">
Welcome to <b>LGMOD</b> and <b>OPENRELEASE</b>! Customized firmware for LG TV Sets!<br><br>
<b>LGMOD</b> functionality will allow you to use USB2NET dongles to add network support to your TV:<br>
mount network shared drives, use UPnP media resources, ssh, telnet, ftp services, etc.<br><br>
<b>OPENRELEASE</b> by rtokarev adds "server" mode, remap remote control buttons and more...<br><br>
Click "System" to see system informations and mounted drives.<br>
Click "Logs" to see system, kernel and RELEASE logs.<br>
Click "Network" to see and configure you TV's network settings.<br>
Click "Drives" to see and configure you TV's network shares and local drives.<br>
Click "Tools" to configure http password to this site and advanced configuration.<br>
Click "Services" to start/stop services, to see all processes.<br>
Click "Remote" to remote control your TV.<br>
Click "RELEASE" to use RELEASE application (dangerous!).<br>
<?
if [ -d /mnt/lg/user/lgmod/init ]; then
	?>
<br>
Click "INIT" to change initialization options (advanced!).<br>
	<?
fi
?>
<br>
Most features require USB Hub & USB Stick constantly plugged.
</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
