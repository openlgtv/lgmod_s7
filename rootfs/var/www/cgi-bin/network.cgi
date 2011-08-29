#!/usr/bin/haserl
content-type: text/html

<? cat /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / NETWORK</p><div class="pagebody">

<div class="post"><div class="posthead">Ethernet Configuration</div><div class="posttext"><form action="network.cgi" method="post">
<b>Use DHCP:</b>
<? ip=`awk '{print $1}' /mnt/lg/user/lgmod/network`
 mask=`awk '{print $2}' /mnt/lg/user/lgmod/network`
 gw=`awk '{print $3}' /mnt/lg/user/lgmod/network`
 dns=`awk '{print $2}' /mnt/lg/user/lgmod/resolv.conf`
 if [ ! -e /mnt/lg/user/lgmod/network -o -e /mnt/lg/user/lgmod/dhcp ]; then 
  flag="disabled" && yes="checked" && no=""
 else 
  flag="" && yes="" && no="checked"
 fi 
 echo "<input name='dhcp' type='radio' value='1' onclick='ip.disabled=true;mask.disabled=true;gw.disabled=true' $yes><b>Yes</b>
<input name='dhcp' type='radio' value='0' onclick='ip.disabled=false;mask.disabled=false;gw.disabled=false' $no><b>No</b><br>
Local IP Address:<input name='ip' type='text' id='ip' $flag value='$ip'>
Subnet Mask:<input name='mask' type='text' id='mask' $flag value='$mask'>
Gateway: <input name='gw' type='text' id='gw' $flag value='$gw'><br><br>
<b>DNS Server:</b><input name='dns' type='text' id='dns' value='$dns'>"
?></div></div>

<div class="post"><div class="posthead">Network Services Configuration</div><div class="posttext"><form action="network.cgi" method="post">
<b>UPnP Client (enable your TV as UPnP ControlPoint/Renderer:</b>
<? if [ -e /mnt/lg/user/lgmod/upnp ]; then
 echo '<input name="pnp" type="checkbox" value="1" checked onclick="cmntp.disabled=!pnp.checked">' && cmntp=`awk '{print $1}' /mnt/lg/user/lgmod/upnp`
 echo "<br>Media mount point (default /mnt/usb1/Drive1/upnp for upnp folder on USB stick first partition) :<input name='cmntp' type='text' id='cmntp' value='$cmntp'><br>"
else
 echo '<input name="pnp" type="checkbox" value="1" onclick="cmntp.disabled=!pnp.checked">' && cmntp=""
 echo "<br>Media mount point (default /mnt/usb1/Drive1/upnp for upnp folder on USB stick first partition) :<input name='cmntp' type='text' id='cmntp' disabled value='$cmntp'><br>"
fi ?> 

<br><b>Launch ssh service at startup:</b>
<? if [ -e /mnt/lg/user/lgmod/ssh ]; then
  echo '<input name="ssh" type="checkbox" value="1" checked>'
else
  echo '<input name="ssh" type="checkbox" value="1">'
fi ?><br>

<br><b>Launch telnetd service at startup:</b>
<? if [ -e /mnt/lg/user/lgmod/telnet ]; then
  echo '<input name="tel" type="checkbox" value="1" checked>'
else
  echo '<input name="tel" type="checkbox" value="1">'
fi ?><br>

<br><b>Launch ftpd service at startup:</b>
<? if [ -e /mnt/lg/user/lgmod/ftp ]; then
 echo '<input name="ftp" type="checkbox" value="1" onclick="pFtp.disabled=!ftp.checked" checked>' && pFtp=`awk '{print $1}' /mnt/lg/user/lgmod/ftp`
 echo "FTP mount point (default /):<input name='pFtp' type='text' id='pFtp' value='$pFtp'><br>"
else
 echo '<input name="ftp" type="checkbox" value="1" onclick="pFtp.disabled=!ftp.checked">' && pFtp=""
 echo "FTP mount point (default /):<input name='pFtp' type='text' id='pFtp' disabled value='$pFtp'><br>"
fi ?><br>

<b>NTP Client:</b>
<? tz=`awk '{print $1}' /mnt/lg/user/lgmod/TZ`
 nip=`awk '{print $1}' /mnt/lg/user/lgmod/ntp`
 if [ -e /mnt/lg/user/lgmod/ntp ]; then 
  flag="" && yes="checked" && no=""
else 
 flag="disabled" && yes="" && no="checked"
fi 
 echo "<input name='ntp' type='radio' value='1' onclick='nip.disabled=false;tz.disabled=false' $yes><b>Enable</b>
<input name='ntp' type='radio' value='0' onclick='nip.disabled=true;tz.disabled=true' $no><b>Disable</b><br>
Server IP/Name:<input name='nip' type='text' id='nip' $flag value='$nip'>
Timezone (e.g GMT-3):<input name='tz' type='text' id='tz' $flag value='$tz'><br>"
?>

</div></div><center><input type="submit" name="save" value="Save config"></center></form>
<?
 if [ "$FORM_save" = "Save config" ]; then
  if [ "$FORM_dhcp" = "1" ]; then
    echo -n > /mnt/lg/user/lgmod/dhcp
  else
    rm /mnt/lg/user/lgmod/dhcp 
    echo -n "$FORM_ip $FORM_mask $FORM_gw" > /mnt/lg/user/lgmod/network
  fi 
  if [ "$FORM_ssh" = "1" ]; then
    echo -n > /mnt/lg/user/lgmod/ssh
  else
    rm /mnt/lg/user/lgmod/ssh
  fi 
  if [ "$FORM_tel" = "1" ]; then
    echo -n > /mnt/lg/user/lgmod/telnet
  else
    rm /mnt/lg/user/lgmod/telnet
  fi 
  if [ "$FORM_ftp" = "1" ]; then
    if [ $FORM_pFtp ]; then
      echo -n $FORM_pFtp > /mnt/lg/user/lgmod/ftp
    else
      echo -n "/" > /mnt/lg/user/lgmod/ftp
    fi
  else
    rm /mnt/lg/user/lgmod/ftp
  fi 
  if [ "$FORM_pnp" = "1" ]; then
    if [ $FORM_cmntp ]; then
      echo -n $FORM_cmntp > /mnt/lg/user/lgmod/upnp
    else
      echo -n "/mnt/usb1/Drive1/upnp" > /mnt/lg/user/lgmod/upnp
    fi
    [ ! -e `cat /mnt/lg/user/lgmod/upnp` ] && mkdir `cat /mnt/lg/user/lgmod/upnp`
  else
    rm /mnt/lg/user/lgmod/upnp
  fi
  if [ "$FORM_ntp" = "1" ]; then
      echo -n $FORM_nip > /mnt/lg/user/lgmod/ntp
      echo $FORM_tz > /mnt/lg/user/lgmod/TZ
  else
    rm /mnt/lg/user/lgmod/ntp
  fi 
  echo "nameserver $FORM_dns" > /mnt/lg/user/lgmod/resolv.conf
  sync
  echo "<script type="text/javascript">window.location.reload()</script>"
 fi ?></div></div></div><br>
<? cat /var/www/cgi-bin/footer.inc ?>
