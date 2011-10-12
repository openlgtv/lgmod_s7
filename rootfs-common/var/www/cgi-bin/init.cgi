#!/usr/bin/haserl
content-type: text/html

<? cat /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / INIT (advanced!)</p><div class="pagebody">

<?
for i in /mnt/lg/user/lgmod/boot /mnt/lg/user/lgmod/release /mnt/lg/user/lgmod/init/rcS-init /mnt/lg/user/lgmod/init/rcS-mount /mnt/lg/user/lgmod/init/lginit-lgmod; do
	n="${i##*/}"; n="${i##*-}"
	if   [ "$n" = boot ];    then save="$FORM_boot"
	elif [ "$n" = release ]; then save="$FORM_release"
	elif [ "$n" = init ];    then save="$FORM_init"
	elif [ "$n" = mount ];   then save="$FORM_mount"
	elif [ "$n" = lgmod ];   then save="$FORM_lgmod"
	else continue; fi
	if [ "$save" = Save ]; then
		echo '<pre>'
		{ echo -n "$FORM_file_content" | dos2unix > "$i"; sync; } 2>&1
		echo "File saved: $i</pre>"
	fi 
	echo "<div class='post'><div class='posthead'>File: $i</div><div class='posttext'>
		<form action='init.cgi' method='post'><textarea name='file_content' rows='10' cols='80'>`cat $i`</textarea>
		<br><input type='submit' name=$n value='Save'></form>
		</div></div>"
done
?>

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
