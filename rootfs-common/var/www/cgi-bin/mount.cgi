#!/usr/bin/haserl
content-type: text/html

<? cat /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / DRIVES</p><div class="pagebody">

<div class="post"><div class="posthead">CD-ROM Drive (Mounted on USB Stick first partition cdrom directory, need to create if does not exist)</div><div class="posttext">
<b>Status :</b><?
if [ "$FORM_mount" = "Mount" ]; then
	mount /dev/cdrom /mnt/usb1/Drive1/cdrom
	[ "$?" = "1" ] && echo '<div class="error"><p align=center><b>COMMAND : mount /dev/cdrom /mnt/usb1/Drive1/cdrom FAILED!</b></p></div>'
elif [ "$FORM_eject" = "Eject" ]; then
	umount /mnt/usb1/Drive1/cdrom
	eject 
fi
mntp=`mount | awk '/cdrom/ {print $3}'`
[ -z $mntp ] && echo "Not mounted" || echo "Mounted ($mntp)"
?>
<br><br><form action="mount.cgi" method="post"><input type="submit" name="mount" value="Mount">
	<input type="submit" name="eject" value="Eject"></form>
</div></div>

<div class="post"><div class="posthead">Configured Drives</div><div class="posttext"><?
CFG_DIR="/mnt/lg/user/lgmod"
FS_MNT=$CFG_DIR/ndrvtab

if [ "$FORM_share" = "Add" ]; then
	if [ "$FORM_lmntp" = "custom" ]; then fs_mount_p="${FORM_umntp}"
	elif [ "$FORM_fs"  = "cifs" ];   then fs_mount_p="${FORM_lmntp}smb"
	elif [ "$FORM_fs"  = "nfs" ];    then fs_mount_p="${FORM_lmntp}nfs"
	elif [ "$FORM_fs"  = "vfat" ] || [ "$FORM_fs" = "ntfs" ] || [ "$FORM_fs" = "ext2" ] || [ "$FORM_fs" = "ext3" ]; then
		fs_mount_p="${FORM_lmntp}local"
	fi

	mkdir -p "$fs_mount_p"
	cp $FS_MNT $FS_MNT.tmp
	echo "$FORM_automnt#$FORM_fs#$FORM_uri#$fs_mount_p#$FORM_opts#$FORM_username#$FORM_pass" >> $FS_MNT
	sync
elif [ "$FORM_action" = "Mount" ]; then
	ndrv=`awk '{ if (NR=='$FORM_didx') { print $0 } }' $FS_MNT`
	automount="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	fs_type="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	src="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	dst="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	opt="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	uname="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	pass="${ndrv%%#*}"; #ndrv="${ndrv#*#}"

	mnt_opt="noatime"
	[ "$uname" ] && mnt_opt="$mnt_opt,user=$uname,pass=$pass"
	[ "$opt" ] && mnt_opt="$mnt_opt,$opt"

	mount -t $fs_type -o "$mnt_opt" "$src" "$dst"
elif [ "$FORM_action" = "Unmount" ]; then
	ndrv=`awk '{ if (NR=='$FORM_didx') { print $0 } }' $FS_MNT`
	automount="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	fs_type="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	src="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	dst="${ndrv%%#*}"; #ndrv="${ndrv#*#}"

	umount "$dst"
elif [ "$FORM_action" = "delete" ]; then
	cp $FS_MNT $FS_MNT.tmp
	awk '{ if (NR!='$FORM_didx') { print $0 } }' $FS_MNT.tmp > $FS_MNT
	sync
fi 2>&1

echo '<table width="95%"><tr><th>Drive</th><th>Mount pt.</th><th>Type</th><th>User</th><th>Pass</th><th>Auto</th><th>Options</th><th>Status</th><th>Action</th></tr>'
didx=1
[ -f $FS_MNT ] && cat $FS_MNT | while read ndrv; do
	automount="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	fs_type="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	src="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	dst="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	opt="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	uname="${ndrv%%#*}"; ndrv="${ndrv#*#}"
	pass="${ndrv%%#*}"; #ndrv="${ndrv#*#}"

	mount | grep -q "$src.*$dst" && { mntstat=Mounted; mntdo=Unmount; } || { mntstat=Unmounted; mntdo=Mount; }
	[ "$automount" = "1" ] && mstat="yes"
	[ "$automount" = "0" ] && mstat="no"

	echo "<tr><td><nobr>$src</nobr></td><td><nobr>$dst</nobr></td><td><nobr>$fs_type</nobr></td><td><nobr>$uname</nobr></td><td><nobr>$pass</nobr></td><td>$mstat</td><td><nobr>$opt</nobr></td><td>$mntstat</td>"
	echo "<td><form action='mount.cgi' method='post'><input type='submit' name='mntdo' value='$mntdo'><input type='hidden' name='action' value='$mntdo'><input type='hidden' name='didx' value='$didx'></form></td>"
	echo "<td><form action='mount.cgi' method='post'><input type='submit' name='mntdo' value='Delete'><input type='hidden' name='action' value='delete'><input type='hidden' name='didx' value='$didx'></form></td></tr>"
	let didx++
done
?></table>
</div></div>

<div class="post"><div class="posthead">Add Drive</div><div class="posttext">
<form action="mount.cgi" method="post"><nobr>
<b>Device Path: </b><input name="uri" type="text" id="uri" size=40>
<b>Type: </b><select name="fs">
	<option value="cifs">SMB</option><option value="nfs">NFS</option>
	<option value="vfat">FAT32</option><option value="ntfs">NTFS</option>
	<option value="ext2">Ext2</option><option value="ext3">Ext3</option></select>
<b>Local Mount Point: </b><select name="lmntp">
	<option value="/mnt/usb1/Drive1/">Drive1</option><option value="/mnt/usb1/Drive2/">Drive2</option>
	<option value="/mnt/usb1/Drive3/">Drive3</option><option value="/mnt/usb1/Drive4/">Drive4</option>
	<option value="custom">Custom..</option></select>
<b>Custom: </b><input name="umntp" type="text" id="umntp">
</nobr><br><br><nobr>
<b>Automount: </b><input type="radio" name="automnt" value="1">Yes<input type="radio" name="automnt" checked="checked" value="0">No
<b>Username: </b><input name="username" type="text" id="username" size=10>
<b>Password: </b><input name="pass" type="password" id="pass" size=10>
<b>Mount options: </b><input name="opts" type="text" id="opts" size=24></nobr>
<hr>NOTE: To use customized mount point select "Custom.." from <b>Local Mount Point</b> and write destination in <b>Custom</b> field by hands.
<br><input type="submit" name="share" value="Add"></form>
</div></div>

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
