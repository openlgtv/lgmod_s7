#!/usr/bin/haserl
content-type: text/html

<? /usr/bin/haserl /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / INIT - Advanced!</p><div class="pagebody">

<div class="post"><div class="posthead">Commands</div><div class="posttext">
<form action="init.cgi" method="post"><input type="submit" name="cmd_reboot" value="Reboot"></form>
<?
[ "$FORM_cmd_reboot" = "Reboot" ] && { echo 'Rebooting...'; reboot; exit; }
?>
</div></div>

<?
for i in rcS rcS-init rcS-mount rcS-relconf lginit lginit-lgmod; do
	name="$i"; dir=/mnt/lg/user/lgmod/init
	if [ "$i" = rcS ]; then save="$FORM_rcS"; text="$FORM_rcS_text"
	elif [ "$i" = rcS-init ]; then name='rcS_init'; save="$FORM_rcS_init"; text="$FORM_rcS_init_text"
	elif [ "$i" = rcS-mount ]; then name='rcS_mount'; save="$FORM_rcS_mount"; text="$FORM_rcS_mount_text"
	elif [ "$i" = rcS-relconf ]; then name='rcS_relconf'; save="$FORM_rcS_relconf"; text="$FORM_rcS_relconf_text"
	elif [ "$i" = lginit ]; then save="$FORM_lginit"; text="$FORM_lginit_text"
	elif [ "$i" = lginit-lgmod ]; then name='lginit_lgmod'; save="$FORM_lginit_lgmod"; text="$FORM_lginit_lgmod_text"
	else continue; fi
	if [ -n "$save" ]; then
		echo "<pre>File saved: $dir/$i"
		echo -n "$text" | dos2unix > "$dir/$i"
		sync; echo '</pre>'
	fi 2>&1
	?>
<div class="post"><div class="posthead">File: <b><? echo -n "$dir/$i" ?></b></div><div class="posttext">
<form action="init.cgi" method="post">
<textarea name="<? echo -n "$name" ?>_text" rows="10" cols="80"><? cat "$dir/$i" ?></textarea>
<br><input type="submit" name="<? echo -n "$name" ?>" value="Save"></form>
</div></div>
	<?
done
?>

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
