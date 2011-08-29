#!/usr/bin/haserl
content-type: text/html

<? /usr/bin/haserl /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / SYSTEM</p><div class="pagebody">

<div class="post"><div class="posthead">System Information</div><div class="posttext">
<pre><? cat /proc/version ?></pre>
</div></div>

<div class="post"><div class="posthead">Uptime</div><div class="posttext">
<pre><? uptime ?></pre>
</div></div>

<div class="post"><div class="posthead">CPU Info</div><div class="posttext">
<pre><? cat /proc/cpuinfo ?></pre>
</div></div>

<div class="post"><div class="posthead">Memory info</div><div class="posttext">
<pre><? free ?></pre>
<pre><? echo "LGAPP is mounted at:`cat /proc/xipfs`" ?></pre>
</div></div>

<div class="post"><div class="posthead">USB info</div><div class="posttext">
<pre><? lsusb ?></pre>
</div></div>

<div class="post"><div class="posthead">Network</div><div class="posttext">
<pre><? /sbin/ifconfig -a ?></pre>
<pre><? /sbin/route ?></pre>
<pre><? cat /etc/resolv.conf ?></pre>
</div></div>

<div class="post"><div class="posthead">Local drives</div><div class="posttext">
<pre><? mount | awk '/vfat|ntfs|isofs|udf|ext2|ext3/' ?></pre>
</div></div>

<div class="post"><div class="posthead">Network drives</div><div class="posttext">
<pre><? mount | awk '/cifs|nfs/' ?></pre>
</div></div>

<div class="post"><div class="posthead">Mounts</div><div class="posttext">
<pre><? cat /proc/mounts ?></pre>
</div></div>

<div class="post"><div class="posthead">Loaded modules</div><div class="posttext">
<pre><? lsmod ?></pre>
</div></div>

<!--
<div class="post"><div class="posthead">Dmesg</div><div class="posttext">
<pre><? #dmesg ?></pre>
</div></div>
-->

<div class="post"><div class="posthead">Exports</div><div class="posttext">
<pre><? export ?></pre>
</div></div>

<div class="post"><div class="posthead">/lg/model/RELEASE.cfg</div><div class="posttext">
<pre><? cat /lg/model/RELEASE.cfg ?></pre>
</div></div>

<!--
<div class="post"><div class="posthead">INIT scripts</div><div class="posttext">
<div class="post"><div class="posthead">/etc/init.d/rcS</div><div class="posttext">
<pre><? #cat /etc/init.d/rcS ?></pre>
</div></div>
<div class="post"><div class="posthead">/etc/rc.d/rc.sysinit</div><div class="posttext">
<pre><? #cat /etc/rc.d/rc.sysinit ?></pre>
</div></div>
<div class="post"><div class="posthead">/etc/rc.d/rc.local</div><div class="posttext">
<pre><? #cat /etc/rc.d/rc.local ?></pre>
</div></div>
<div class="post"><div class="posthead">/etc/lgmod.sh</div><div class="posttext">
<pre><? #cat /etc/lgmod.sh ?></pre>
</div></div>
</div></div>
-->

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
