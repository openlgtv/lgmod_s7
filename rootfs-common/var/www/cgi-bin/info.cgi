#!/usr/bin/haserl
content-type: text/html

<? cat /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / SYSTEM</p><div class="pagebody">

<div class="post"><div class="posthead">System Information</div><div class="posttext">
<pre><? for i in /proc/version '/etc/version_for_lg ' /proc/version_for_lg; do echo -n "$i: "; cat $i 2>&1; done
	echo; echo -n 'Uptime: '; uptime 2>&1 ?></pre>
</div></div>

<div class="post"><div class="posthead">CPU Info (/proc/cpuinfo)</div><div class="posttext">
<pre><? cat /proc/cpuinfo 2>&1 ?></pre>
</div></div>

<div class="post"><div class="posthead">Memory info (free)</div><div class="posttext">
<pre><? free 2>&1; echo; echo "LGAPP is mounted at: $appxip_addr"; cat /proc/xipfs 2>&1 ?></pre>
</div></div>

<div class="post"><div class="posthead">USB info (lsusb)</div><div class="posttext">
<pre><? lsusb 2>&1 ?></pre>
</div></div>

<div class="post"><div class="posthead">Modules (lsmod)</div><div class="posttext">
<pre><? lsmod 2>&1 ?></pre>
</div></div>

<div class="post"><div class="posthead">Network</div><div class="posttext">
<pre><? /sbin/ifconfig -a 2>&1; echo; /sbin/route 2>&1; echo; cat /etc/resolv.conf 2>&1 ?></pre>
</div></div>

<div class="post"><div class="posthead">Network drives</div><div class="posttext">
<pre><? mount | awk '/cifs|nfs/' ?></pre>
</div></div>

<div class="post"><div class="posthead">Local drives</div><div class="posttext">
<pre><? mount | awk '/vfat|ntfs|isofs|udf|ext2|ext3/' ?></pre>
</div></div>

<div class="post"><div class="posthead">/proc/mounts</div><div class="posttext">
<pre><? cat /proc/mounts 2>&1 ?></pre>
</div></div>

<div class="post"><div class="posthead">export</div><div class="posttext">
<pre><? export ?></pre>
</div></div>

<div class="post"><div class="posthead">/mnt/lg/model/RELEASE.cfg</div><div class="posttext">
<pre><? cat /mnt/lg/model/RELEASE.cfg 2>&1 ?></pre>
</div></div>

<div class="post"><div class="posthead">INIT</div><div class="posttext">
<pre><? [ -f /mnt/lg/user/lgmod/boot ] && cat /mnt/lg/user/lgmod/boot 2>&1
	[ -f /mnt/lg/user/lgmod/release ] && cat /mnt/lg/user/lgmod/release 2>&1 ?></pre>
</div></div>

<!--
<div class="post"><div class="posthead">INIT scripts</div><div class="posttext">
<div class="post"><div class="posthead">/etc/init.d/rcS</div><div class="posttext">
<pre>< ? cat /etc/init.d/rcS ? ></pre>
</div></div>
<div class="post"><div class="posthead">/etc/rc.d/rc.sysinit</div><div class="posttext">
<pre>< ? cat /etc/rc.d/rc.sysinit ? ></pre>
</div></div>
<div class="post"><div class="posthead">/etc/rc.d/rc.local</div><div class="posttext">
<pre>< ? cat /etc/rc.d/rc.local ? ></pre>
</div></div>
<div class="post"><div class="posthead">/etc/lgmod.sh</div><div class="posttext">
<pre>< ? cat /etc/lgmod.sh ? ></pre>
</div></div>
</div></div>
-->

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
