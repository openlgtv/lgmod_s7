#!/usr/bin/haserl
content-type: text/html

<? cat /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / LOGS</p><div class="pagebody">

<div class="post"><div class="posthead">logread</div><div class="posttext">
<pre><? logread ?></pre>
</div></div>

<div class="post"><div class="posthead">dmesg</div><div class="posttext">
<pre><? dmesg ?></pre>
</div></div>

<div class="post"><div class="posthead">openrelease.log - require OPENRELEASE mode</div><div class="posttext">
<pre><? cat /tmp/openrelease.log 2>&1 ?></pre>
</div></div>

<div class="post"><div class="posthead">RELEASE.out - require tmux-pipe mode</div><div class="posttext">
<? [ -f /tmp/RELEASE.out ] && { cat /tmp/RELEASE.out | /home/lgmod/ansi2html.sh --bg=dark; } 2>&1 ?>
</div></div>

<div class="post"><div class="posthead">openrelease.out - require OPENRELEASE mode</div><div class="posttext">
<? [ -f /tmp/openrelease.out ] && { cat /tmp/openrelease.out | /home/lgmod/ansi2html.sh --bg=dark; } 2>&1 ?>
</div></div>

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
