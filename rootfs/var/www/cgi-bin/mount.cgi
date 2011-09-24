#!/usr/bin/haserl
content-type: text/html

<? cat /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / DRIVES</p><div class="pagebody">

<div class="post"><div class="posthead">CD-ROM Drive (Mounted on USB Stick first partition cdrom directory, need to create if does not exist)</div><div class="posttext">
<b>Status :</b>
<? mntp=`mount | awk '/cdrom/ {print $3}'`
    if [ -z $mntp ]; then
	echo "Not mounted"
    else
	echo "Mounted ($mntp)"
fi ?>
<br><br>
<form action="mount.cgi" method="post">
<input type="submit" name="mount" value="Mount">
<input type="submit" name="eject" value="Eject">
</form>
<?
 if [ "$FORM_mount" = "Mount" ]; then
    mount /dev/cdrom /mnt/usb1/Drive1/cdrom

    if [ "$?" = "1" ]; then
	echo "<div class="error"><p align=center><b>COMMAND : mount /dev/cdrom /mnt/usb1/Drive1/cdrom FAILED!</b></p></div>"
	sleep 2
    fi
        echo "<script language="javascript" type="text/javascript">location.href='mount.cgi';</script>"
fi

if [ "$FORM_eject" = "Eject" ]; then
  umount /mnt/usb1/Drive1/cdrom
  eject 
    echo "<script language="javascript" type="text/javascript">location.href='mount.cgi';</script>"
fi ?>
</div></div>

<div class="post"><div class="posthead">Configured Drives</div><div class="posttext">
<table width="95%">
<tr>
<th>Drive</th>
<th>Mount pt.</th>
<th>Type</th>
<th>User</th>
<th>Pass</th>
<th>Auto</th>
<th>Options</th>
<th>Status</th>
<th>Action</th>
</tr>

<?
didx=1
cat /mnt/lg/user/lgmod/ndrvtab | while read ndrv; do
    automount=`echo $ndrv | awk -F# '{print $1}'`
    fs_type=`echo $ndrv | awk -F# '{print $2}'`
    src=`echo $ndrv | awk -F# '{print $3}'`
    dst=`echo $ndrv | awk -F# '{print $4}'`
    opt=`echo $ndrv | awk -F# '{print $5}'`
    uname=`echo $ndrv | awk -F# '{print $6}'`
    pass=`echo $ndrv | awk -F# '{print $7}'`
    mntstat=`mount | grep "$src.*$dst"`

if [ "$automount" = "1" ]; then mstat="yes"; fi
if [ "$automount" = "0" ]; then mstat="no"; fi

echo "<tr><td>$src</td><td>$dst</td><td>$fs_type</td><td>$uname</td><td>$pass</td><td>$mstat</td><td>$opt</td>"
if [ "$mntstat" ];
then
    echo "<td>Mounted</td><td><form action="mount.cgi" method="post"><input type="submit" name="numount" value="Unmount"><input type="hidden" name="action" value="unmount"><input type="hidden" name="didx" value="$didx">"
else
    echo "<td>Unmounted</td><td><form action="mount.cgi" method="post"><input type="submit" name="nmount" value="Mount"><input type="hidden" name="action" value="mount"><input type="hidden" name="didx" value="$didx">"
fi
echo "</form></td><td><form action="mount.cgi" method="post"><input type="submit" name="nmdel" value="Delete"><input type="hidden" name="action" value="delete"><input type="hidden" name="didx" value="$didx">"
echo "</form></td></tr>"
let didx++
done
?>
</table>
</div></div>
<?
    if [ "$FORM_action" = "mount" ]; then
        ndrv=`awk '{ if (NR=='$FORM_didx') { print $0 } }' /mnt/lg/user/lgmod/ndrvtab`
        
        automount=`echo $ndrv | awk -F# '{print $1}'`
	fs_type=`echo $ndrv | awk -F# '{print $2}'`
	src=`echo $ndrv | awk -F# '{print $3}'`
	dst=`echo $ndrv | awk -F# '{print $4}'`
	opt=`echo $ndrv | awk -F# '{print $5}'`
	uname=`echo $ndrv | awk -F# '{print $6}'`
	pass=`echo $ndrv | awk -F# '{print $7}'`
	
	mntstat=`mount | grep $dst`
	
	mnt_opt="-o noatime";
	
	[ "$uname" ] && mnt_opt="$(echo $mnt_opt,user=$uname,pass=$pass)" 
	[ "$opt" ] && mnt_opt="${mnt_opt},${opt}"
	
        mount -t $fs_type $mnt_opt $src $dst
        echo "<script language="javascript" type="text/javascript">location.href='mount.cgi';</script>"
    fi

    if [ "$FORM_action" = "unmount" ]; then
        ndrv=`awk '{ if (NR=='$FORM_didx') { print $0 } }' /mnt/lg/user/lgmod/ndrvtab`
	dst=`echo $ndrv | awk -F# '{print $4}'`
	umount $dst
        echo "<script language="javascript" type="text/javascript">location.href='mount.cgi';</script>"
    fi

    if [ "$FORM_action" = "delete" ]; then
	cp /mnt/lg/user/lgmod/ndrvtab /mnt/lg/user/lgmod/ndrvtab.tmp
	awk '{ if (NR!='$FORM_didx') { print $0 } }' /mnt/lg/user/lgmod/ndrvtab.tmp > /mnt/lg/user/lgmod/ndrvtab
	echo "<script language="javascript" type="text/javascript">location.href='mount.cgi';</script>"
    fi
?>

<div class="post"><div class="posthead">Add Drive</div><div class="posttext">
<form action="mount.cgi" method="post">
<b>Device Path: </b><input name="uri" type="text" id="uri" size=40>
<b>Type: </b><select name="fs">
<option value="cifs">SMB</option><option value="nfs">NFS</option>
<option value="vfat">FAT32</option><option value="ntfs">NTFS</option>
<option value="ext2">Ext2</option><option value="ext3">Ext3</option>
</select>
<b>Local Mount Point: </b>
<select name="lmntp">
<option value="/mnt/usb1/Drive1/">Drive1</option>
<option value="/mnt/usb1/Drive2/">Drive2</option>
<option value="/mnt/usb1/Drive3/">Drive3</option>
<option value="/mnt/usb1/Drive4/">Drive4</option>
<option value="custom">Custom..</option>
</select>
<b>Automount: </b><input type="radio" name="automnt" value="1">Yes<input type="radio" name="automnt" checked="checked" value="0">No
<br><br>
<b>Username: </b><input name="username" type="text" id="username" size=10>
<b>Password: </b><input name="pass" type="password" id="pass" size=10>
<b>Additional mount options: </b><input name="opts" type="text" id="opts" size=24>
<b>Custom: </b><input name="umntp" type="text" id="umntp">
<hr>
NOTE: To use customized mount point select "Custom.." from <b>Local Mount Point</b> and write destination in <b>Custom</b> field by hands.
<br>
<input type="submit" name="share" value="Add">
</form>
<?
 if [ "$FORM_share" = "Add" ]; then
        
    [ "$FORM_fs" = "vfat" ] && 	fs_mount_p="${FORM_lmntp}local"
    [ "$FORM_fs" = "ntfs" ] && 	fs_mount_p="${FORM_lmntp}local"
    [ "$FORM_fs" = "ext2" ] && 	fs_mount_p="${FORM_lmntp}local"
    [ "$FORM_fs" = "ext3" ] && 	fs_mount_p="${FORM_lmntp}local"
    [ "$FORM_fs" = "cifs" ] && fs_mount_p="${FORM_lmntp}smb"
    [ "$FORM_fs" = "nfs" ] && fs_mount_p="${FORM_lmntp}nfs"
    
    if [ "$FORM_lmntp" = "custom" ]; then
	fs_mount_p="${FORM_umntp}"
    fi
    
    echo "$FORM_automnt#$FORM_fs#$FORM_uri#$fs_mount_p#$FORM_opts#$FORM_username#$FORM_pass" >> /mnt/lg/user/lgmod/ndrvtab
    echo "<script language="javascript" type="text/javascript">location.href='mount.cgi';</script>"

 fi
?>
</div></div>

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
