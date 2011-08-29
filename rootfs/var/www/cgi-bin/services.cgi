#!/usr/bin/haserl
content-type: text/html

<? /usr/bin/haserl /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / SERVICES</p><div class="pagebody">

<div class="post"><div class="posthead">Services</div><div class="posttext">
<form action="services.cgi" method="get"><?
[ -n "$FORM_cmd" ] && echo "<pre>$($FORM_cmd 2>&1)</pre>"

#for i in /etc/init.d/??[a-z]*; do
pgrep=''
for i in /etc/init.d/??[^SK]*; do
	I="${i##*/}"
	[ "$I" = lgmod ] && continue
	pgrep="$pgrep|$I"
done
pgrep=$(pgrep -fl "$pgrep") 2>&1

echo '<table>'
for i in /etc/init.d/??[^SK]*; do
	I="${i##*/}"
	echo "<tr><td><a href='?cmd=$i start'>start</a>&nbsp;</td><td><a href='?cmd=$i stop'>stop</a>&nbsp;"
	echo "</td><td><a href='?cmd=$i restart'>restart</a>&nbsp;</td><td><nobr>$I</nobr>&nbsp;</td><td><nobr>"
	echo -n "$pgrep" | grep -m1 $I; echo '</nobr></td></tr>'
done
echo '</table>'
?></form></div></div>

<div class="post"><div class="posthead">Processes (long)</div><div class="posttext">
<pre><? ps axl 2>&1 ?></pre>
</div></div>

<div class="post"><div class="posthead">Processes (tree)</div><div class="posttext">
<pre><? ps axf 2>&1 ?></pre>
</div></div>

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
