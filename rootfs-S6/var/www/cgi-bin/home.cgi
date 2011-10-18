#!/usr/bin/haserl
content-type: text/html

<html>
<? cat /var/www/cgi-bin/header.inc ?>
<body>

<hr>
<p class="largefont">LGMOD CONFIGURATION / HOME</p>
<div id="navbar">Home&nbsp;&nbsp;&nbsp<a href="info.cgi">System Info</a>&nbsp;&nbsp;&nbsp;<a href="network.cgi">Network</a>&nbsp;&nbsp;&nbsp;<a href="mount.cgi">Drives</a>&nbsp;&nbsp;&nbsp;<a href="tools.cgi">Tools</a></div>
<div class="pagebody">

<div class="post"><div class="posttext">
Welcome to LGMOD! Customized firmware for LG TV Sets!<br>
LGMOD functionality will allow you to use USB2NET dongles to add network support to your TV :<br>
mount filesystems
use UPnP media resources
use samba shares, etc..<br><br>
Click "System Info" to see system informations and mounted drives.<br>
Click "Network" to see and configure you TV's network settings.<br>
Click "Drives" to see and configure you TV's network shares and local drives.<br>
Click "Tools" to configure http password to this site and advanced configuration.<br>
<br>
For this mod to work you need USB Hub & USB Stick constantly plugged.
</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
</body></html>
