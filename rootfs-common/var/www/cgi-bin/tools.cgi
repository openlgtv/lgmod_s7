#!/usr/bin/haserl --upload-limit=16384 --upload-dir=/tmp/lgmod/Upload
content-type: text/html

<? cat /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / TOOLS</p><div class="pagebody">

<div class="post"><div class="posthead">Security</div><div class="posttext">
<form action="tools.cgi" method="post">
<? 
if [ "$FORM_change" = "Change" ]; then
	{ cp /mnt/lg/user/lgmod/httpd.conf /tmp/httpd.conf.tmp
	old_pw=`awk -F: '/cgi-bin/ {print $3}' /mnt/lg/user/lgmod/httpd.conf`
	sed "s/$old_pw/$FORM_passwd/" /tmp/httpd.conf.tmp > /mnt/lg/user/lgmod/httpd.conf
	rm /tmp/httpd.conf.tmp; sync; } 2>&1
	echo "<div class="ok"><p align=center><b>Restart your TV to apply changes</b></p></div>"
fi

pass=`awk -F: '/cgi-bin/ {print $3}' /mnt/lg/user/lgmod/httpd.conf`
echo "WebUI access password: <input name="passwd" type="password" id="passwd" size=10 value="$pass">"
?>
<input type="submit" name="change" value="Change">
</form>
</div></div>

<div class="post"><div class="posthead">Execute shell command</div><div class="posttext">
<form action="tools.cgi" method="post">
<input name="shell" type="text" size=48>
<input type="submit" name="run" value="Run">
</form>
<?
if [ "$FORM_run" = "Run" ]; then
	echo -n "$FORM_shell" > /tmp/shell_command.sh
	echo "$FORM_shell"; echo
	dos2unix /tmp/shell_command.sh
	chmod +x /tmp/shell_command.sh
	/tmp/shell_command.sh &> /tmp/shell_command.out
	rm /tmp/shell_command.sh
	sync
	echo "<pre>"
	cat /tmp/shell_command.out
	rm /tmp/shell_command.out
	echo "</pre>"
fi
?>
</div></div>

<div class="post"><div class="posthead">Upload file to USB drive into "LG_DTV" folder. If folder does not exist, it will be created.</div><div class="posttext">
<form action="tools.cgi" method="post" enctype="multipart/form-data" >
<input type=file name=uploadfile><input type=submit value=Upload><br><?
if [ -n "$FORM_uploadfile_name" ]; then 
	[ -e /mnt/usb1/Drive1/LG_DTV ] || mkdir /mnt/usb1/Drive1/LG_DTV
	if [ -e /mnt/usb1/Drive1/LG_DTV ]; then
		echo 3 > /proc/sys/vm/drop_caches; sleep 1
		cp -f $HASERL_uploadfile_path /mnt/usb1/Drive1/LG_DTV/$FORM_uploadfile_name
		sync
		if [ -e /mnt/usb1/Drive1/LG_DTV/$FORM_uploadfile_name ]; then
			echo "File /mnt/usb1/Drive1/LG_DTV/<b>$FORM_uploadfile_name</b> is uploaded."
		else
			echo "<b>Error! Cannot upload file. Probably USB drive is read only."
		fi
	else
		echo "Cannot create LG_DTV folder. Probably USB drive is read only."
	fi
else
	echo "Select file and press Upload button."
fi
?></form>
</div></div>

<div class="post"><div class="posthead">LG_DTV Folder contents</div><div class="posttext">
<pre><? ls -l /mnt/usb1/Drive1/LG_DTV ?></pre>
</div></div>

<div class="post"><div class="posthead">Autostart script (to be executed after lgmod (network available) and RELEASE running (USB available))</div><div class="posttext">
<form action="tools.cgi" method="post"><? 
if [ "$FORM_save1" = "Save" ]; then
	echo -n "$FORM_script1" > /mnt/lg/user/lgmod/auto_start.sh
	dos2unix /mnt/lg/user/lgmod/auto_start.sh
	sync
	echo "<script language="javascript" type="text/javascript">location.href='tools.cgi';</script>"
fi
if [ "$FORM_execute1" = "Execute" ]; then
	/mnt/lg/user/lgmod/auto_start.sh
fi

txt=`cat /mnt/lg/user/lgmod/auto_start.sh`; echo "<textarea name='script1' rows='10' cols='80'>$txt</textarea>"
?><br><input type="submit" name="save1" value="Save">
<input type="submit" name="execute1" value="Execute"></form>
</div></div>

<div class="post"><div class="posthead">Autostop script</div><div class="posttext">
<form action="tools.cgi" method="post"><?
if [ "$FORM_save11" = "Save" ]; then
	echo -n "$FORM_script11" > /mnt/lg/user/lgmod/auto_stop.sh
	dos2unix /mnt/lg/user/lgmod/auto_stop.sh
	sync
	echo "<script language="javascript" type="text/javascript">location.href='tools.cgi';</script>"
fi
if [ "$FORM_execute11" = "Execute" ]; then
	/mnt/lg/user/lgmod/auto_stop.sh
fi

txt=`cat /mnt/lg/user/lgmod/auto_stop.sh`; echo "<textarea name='script11' rows='10' cols='80'>$txt</textarea>"
?><br><input type="submit" name="save11" value="Save">
<input type="submit" name="execute11" value="Execute"></form>
</div></div>

<div class="post"><div class="posthead">Modules configuration script (you can comment/uncomment/add modules to fit your needs)</div><div class="posttext">
<form action="tools.cgi" method="post"><?
if [ "$FORM_save2" = "Save" ]; then
	echo -n "$FORM_script2" > /mnt/lg/user/lgmod/module.sh
	dos2unix /mnt/lg/user/lgmod/module.sh
	sync
	echo "<script language="javascript" type="text/javascript">location.href='tools.cgi';</script>"
fi

txt=`cat /mnt/lg/user/lgmod/module.sh`; echo "<textarea name='script2' rows='10' cols='80'>$txt</textarea>"
?><br><input type="submit" name="save2" value="Save"></form>
</div></div>

<div class="post"><div class="posthead">Patch script (executed before RELEASE and LGMOD)</div><div class="posttext">
<form action="tools.cgi" method="post"><?
if [ "$FORM_save3" = "Save" ]; then
	echo -n "$FORM_script3" > /mnt/lg/user/lgmod/patch.sh
	dos2unix /mnt/lg/user/lgmod/patch.sh
	sync
	echo "<script language="javascript" type="text/javascript">location.href='tools.cgi';</script>"
fi

txt=`cat /mnt/lg/user/lgmod/patch.sh`; echo "<textarea name='script3' rows='10' cols='80'>$txt</textarea>"
?><br><input type="submit" name="save3" value="Save"></form>
</div></div>

<div class="post"><div class="posthead">INIT (careful!)</div><div class="posttext">
<form action="tools.cgi#goto_bottom" method="post"><?
if [ "$FORM_cmd_reboot" = "Reboot" ]; then
	echo '<script language="javascript" type="text/javascript">setTimeout(function(){ location.href="tools.cgi"; }, 45000);</script>'
	echo 'Rebooting... (auto reload in 45 seconds...)<a name="goto_bottom"></a>'
	reboot; exit
fi

MNT=/mnt/lg/user; BOOTMOD=$MNT/lgmod/boot
RELMOD=/mnt/lg/user/lgmod/release

{
if [ "$FORM_save_init" = "Save" ]; then
	if [ ! -d /mnt/lg/lginit ]; then # S6
		n=RCS_CHROOT; v="$FORM_RCS_CHROOT"; [ -f $BOOTMOD ] && grep -q "^$n=" $BOOTMOD && sed -ie "/^$n=/d" $BOOTMOD
			[ -n "$v" ] && echo "$n=$v" >> $BOOTMOD
	else # S7
		n=LGI_MENU; v="$FORM_LGI_MENU"; [ -f $BOOTMOD ] && grep -q "^$n=" $BOOTMOD && sed -ie "/^$n=/d" $BOOTMOD
			[ -n "$v" ] && echo "$n=$v" >> $BOOTMOD
		n=LGI_CHROOT; v="$FORM_LGI_CHROOT"; [ -f $BOOTMOD ] && grep -q "^$n=" $BOOTMOD && sed -ie "/^$n=/d" $BOOTMOD
			[ -n "$v" ] && echo "$n=$v" >> $BOOTMOD
	fi
	n=RCS_SYSLOG; v="$FORM_RCS_SYSLOG"; [ -f $BOOTMOD ] && grep -q "^$n=" $BOOTMOD && sed -ie "/^$n=/d" $BOOTMOD
		[ -n "$v" ] && echo "$n=$v" >> $BOOTMOD
	n=RCS_NOREL; v="$FORM_RCS_NOREL"; [ -f $BOOTMOD ] && grep -q "^$n=" $BOOTMOD && sed -ie "/^$n=/d" $BOOTMOD
		[ -n "$v" ] && echo "$n=$v" >> $BOOTMOD
	n=RCS_NOREL_ONCE; v="$FORM_RCS_NOREL_ONCE"; [ -f $BOOTMOD ] && grep -q "^$n=" $BOOTMOD && sed -ie "/^$n=/d" $BOOTMOD
		[ -n "$v" ] && echo "$n=$v" >> $BOOTMOD
	n=RCS_CRASHDOG; v="$FORM_RCS_CRASHDOG"; [ -f $BOOTMOD ] && grep -q "^$n=" $BOOTMOD && sed -ie "/^$n=/d" $BOOTMOD
		[ -n "$v" ] && echo "$n=$v" >> $BOOTMOD

	n=MODE; v="$FORM_MODE"; [ -f $RELMOD ] && grep -q "^$n=" $RELMOD && sed -ie "/^$n=\|^$/d" $RELMOD
		[ -n "$v" ] && echo "$n=$v" >> $RELMOD
		[ -f $RELMOD ] && [ ! -s $RELMOD ] && rm -f $RELMOD

	sync
fi

if [ ! -d /mnt/lg/lginit ]; then # S6
	n=RCS_CHROOT; v=sda1/lgmod_s6.sqf; c=''; [ -f $BOOTMOD ] && grep -q "^$n=$v$" $BOOTMOD && c=checked
		echo "<b>Chroot to sda1/lgmod_s6.sqf </b><input name=$n type=checkbox value='$v' $c><br>"
else # S7
	n=LGI_MENU; v=0; c=''; [ -f $BOOTMOD ] && grep -q "^$n=$v$" $BOOTMOD && c=checked
		echo "<b>Disable lginit menu ('Press any key for shell') </b><input name=$n type=checkbox value='$v' $c><br>"
	n=LGI_CHROOT; v=sda1/lgmod_s7.sqf; c=''; [ -f $BOOTMOD ] && grep -q "^$n=$v$" $BOOTMOD && c=checked
		echo "<b>Chroot to sda1/lgmod_s7.sqf </b><input name=$n type=checkbox value='$v' $c><br>"
fi
n=RCS_SYSLOG; v=0; c=''; [ -f $BOOTMOD ] && grep -q "^$n=$v$" $BOOTMOD && c=checked
	echo "<b>Disable syslogd </b><input name=$n type=checkbox value='$v' $c><br>"
n=RCS_NOREL; v=1; c=''; [ -f $BOOTMOD ] && grep -q "^$n=$v$" $BOOTMOD && c=checked
	echo "<b>Disable RELEASE start </b><input name=$n type=checkbox value='$v' $c> "
n=RCS_NOREL_ONCE; v=1; c=''; [ -f $BOOTMOD ] && grep -q "^$n=$v$" $BOOTMOD && c=checked
	echo "<b> once at next restart only </b><input name=$n type=checkbox value='$v' $c><br>"
n=RCS_CRASHDOG; v=1; c=''; [ -f $BOOTMOD ] && grep -q "^$n=$v$" $BOOTMOD && c=checked
	echo "<b>Enable (force) crashdog (watch mount cramfs and RELEASE startup) </b><input name=$n type=checkbox value='$v' $c><br>"

echo '<br><b>RELEASE startup mode:</b><br>'
#n=MODE; v=OPENREL-TMUX-PIPE; c=''; [ -f $RELMOD ] && grep -q "^$n=$v$" $RELMOD && c=checked
#	echo "$v <input name=$n type=checkbox value='$v' $c><br>"
n=MODE; v=OPENREL-TMUX; c=''; [ -f $RELMOD ] && grep -q "^$n=$v$" $RELMOD && c=checked
	echo "$v <input name=$n type=checkbox value='$v' $c><br>"
n=MODE; v=OPENRELEASE; c=''; [ -f $RELMOD ] && grep -q "^$n=$v$" $RELMOD && c=checked
	echo "$v <input name=$n type=checkbox value='$v' $c><br>"
n=MODE; v=OPENREL-DAEMON; c=''; [ -f $RELMOD ] && grep -q "^$n=$v$" $RELMOD && c=checked
	echo "$v (recommended) <input name=$n type=checkbox value='$v' $c><br>"
n=MODE; v=TMUX-PIPE; c=''; [ -f $RELMOD ] && grep -q "^$n=$v$" $RELMOD && c=checked
	echo "$v <input name=$n type=checkbox value='$v' $c><br>"
n=MODE; v=TMUX; c=''; [ -f $RELMOD ] && grep -q "^$n=$v$" $RELMOD && c=checked
	echo "$v <input name=$n type=checkbox value='$v' $c><br>"
n=MODE; v=LG; c=''; [ -f $RELMOD ] && grep -q "^$n=$v$" $RELMOD && c=checked
	echo "$v default <input name=$n type=checkbox value='$v' $c><br><br>"
} 2>&1
?>Note: Try before save: 1) Disable RELEASE and restart TV; 2) Start 'release' manually ('Services' page, default is OPENREL-DAEMON)<br><br>
<input type="submit" name="save_init" value="Save"><input type="submit" name="cmd_reboot" value="Reboot"></form><a name='goto_bottom'></a>
</div></div>

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
