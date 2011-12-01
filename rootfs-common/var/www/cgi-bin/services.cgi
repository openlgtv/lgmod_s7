#!/usr/bin/haserl
content-type: text/html

<? cat /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / SERVICES</p><div class="pagebody">

<div class="post"><div class="posthead">Services</div><div class="posttext">
<form action="services.cgi" method="get"><?
[ -n "$FORM_cmd" ] && { echo '<pre>'; $FORM_cmd 2>&1; echo '</pre>'; sleep 0.2; }

echo '<table>'
#for i in /etc/init.d/??[a-z]*; do
for i in /etc/init.d/??[^SK]*; do
	I="${i##*/}"
	#[ "$I" = lgmod ] && continue
	echo "<tr><td><a href='?cmd=$i start'>start</a>&nbsp;</td><td><a href='?cmd=$i stop'>stop</a>&nbsp;"
	echo "</td><td><a href='?cmd=$i restart'>restart</a>&nbsp;</td><td>&nbsp;<nobr>$I</nobr>&nbsp;&nbsp;</td><td><pre>"
	if [ "$I" = release ]; then pgrep -fl '^/mnt/lg/lgapp/RELEASE'
	elif [ "$I" = ftpd ]; then pgrep -fl 'ftpd'
	else pgrep -fl "^\(/[a-z/]*/\)\?$I "; fi
	echo '</pre></td></tr>'
done
echo '</table>'
?></form></div></div>

<div class="post"><div class="posthead">Processes</div><div class="posttext">
<?
echo -n '<pre>'
if [ -h /bin/ps ]; then
	ps w
else
	ps axl 2>&1
	echo -n '</pre><br><pre>'
	ps axf 2>&1
fi
echo '</pre>'
?>
</div></div>

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
