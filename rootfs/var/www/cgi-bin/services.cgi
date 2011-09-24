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
	[ "$I" = lgmod ] && continue
	echo "<tr><td><a href='?cmd=$i start'>start</a>&nbsp;</td><td><a href='?cmd=$i stop'>stop</a>&nbsp;"
	echo "</td><td><a href='?cmd=$i restart'>restart</a>&nbsp;</td><td>&nbsp;<nobr>$I</nobr>&nbsp;&nbsp;</td><td><pre>"
	if [ "$I" = release ]; then pgrep -fl '^/mnt/lg/lgapp/RELEASE'
	else pgrep -fl "$I"; fi
	echo '</pre></td></tr>'
done
echo '</table>'
?></form></div></div>

<div class="post"><div class="posthead">Processes - long (as axl)</div><div class="posttext">
<pre><? ps axl 2>&1 ?></pre>
</div></div>

<div class="post"><div class="posthead">Processes - tree (ps axf)</div><div class="posttext">
<pre><? ps axf 2>&1 ?></pre>
</div></div>

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
