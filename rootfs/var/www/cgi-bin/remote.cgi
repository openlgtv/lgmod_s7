#!/usr/bin/haserl
content-type: text/html

<? cat /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / REMOTE</p><div class="pagebody">

<?
if [ -n "$FORM_code" ]; then
	echo "Code: $FORM_code"
	out=$(if [ -e /tmp/openrelease.in ]; then echo "mc 01 $FORM_code" > /tmp/openrelease.in
		else tmux send-keys -t RELEASE "mc 01 $FORM_code" C-m
		fi 2>&1)
	if [ -n "$out" ]; then
		echo "<pre><b>Output: $out"
		echo 'Note: require "debug status=EVENT" or production mode; require OPENRELEASE or tmux</b></pre>'
	else
		echo '<script language="javascript" type="text/javascript">history.back();</script>'
		exit
	fi
fi
?>

<div class="post"><div class="posthead">REMOTE (require "debug status=EVENT" or production mode; require OPENRELEASE or tmux)</div><div class="posttext" align="center">
<br>
<form action="remote.cgi" method="post"><input type="hidden" name="code" value="">
<table width=1%><tr>
<td width=49%></td><td colspan=3></td><td width=49%></td>
</tr><tr>
<td colspan=5 align=center><nobr>
<input type="submit" onClick="javascript:this.form.code.value=08" name="power" value="POWER">
<input type="submit" onClick="javascript:this.form.code.value=95" name="rcbtn" value="Energy">
<input type="submit" onClick="javascript:this.form.code.value=30" name="rcbtn" value="A/V">
<input type="submit" onClick="javascript:this.form.code.value=0b" name="input" value="Input">
<input type="submit" onClick="javascript:this.form.code.value=f0" name="rcbtn" value="TV/RAD">
</nobr></td>
</tr><tr>
<td colspan=5 align=center><nobr>
<input type="submit" onClick="javascript:this.form.code.value=c8" name="usb"   value="USB">
<input type="submit" onClick="javascript:this.form.code.value=''" name="comp1" value="Comp1?">
<input type="submit" onClick="javascript:this.form.code.value=''" name="tv"    value="TV ?">
<input type="submit" onClick="javascript:this.form.code.value=''" name="hdmi1" value="HDMI1?">
<input type="submit" onClick="javascript:this.form.code.value=''" name="hdmi2" value="HDMI2?">
</nobr></td>
</tr><tr><td>&nbsp;</td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=11" name="1" value="1"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=12" name="2" value="2"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=13" name="3" value="3"></td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=14" name="4" value="4"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=15" name="5" value="5"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=16" name="6" value="6"></td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=17" name="7" value="7"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=18" name="8" value="8"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=19" name="9" value="9"></td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=53" name="list"   value="List"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=00" name="0"      value="0"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=1a" name="q_view" value="Q.View"></td>
</tr><tr><td>&nbsp;</td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=02" name="vol_up" value="+"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=1e" name="fav"    value="FAV"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=00" name="pr_up"  value="+"></td>
</tr><tr>
<td colspan=2 align=right><b>VOL</b>&nbsp;&nbsp;</td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=79" name="ratio" value="RATIO"></td>
<td>&nbsp;&nbsp;<b>PRG</b></td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=03" name="vol_down" value="-"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=09" name="mute"     value="MUTE"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=01" name="pr_down"  value="-"></td>
</tr><tr><td>&nbsp;</td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=43" name="rcbtn" value="Menu"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=40" name="rcbtn" value="/\"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=45" name="rcbtn" value="Q.Menu"></td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=07" name="left"  value="<"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=44" name="ok"    value="OK"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=06" name="right" value=">"></td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=28" name="back"  value="Back"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=41" name="rcbtn" value="\/"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=5b" name="rcbtn" value="Exit"></td>
</tr><tr><td>&nbsp;</td>
</tr><tr>
<td colspan=5 align=center>
<input type="submit" onClick="javascript:this.form.code.value=ab" name="rcbtn" value="Guide">
<input type="submit" onClick="javascript:this.form.code.value=aa" name="rcbtn" value="Info">
<input type="submit" onClick="javascript:this.form.code.value=59" name="rcbtn" value="Netcast">
<input type="submit" onClick="javascript:this.form.code.value=91" name="rcbtn" value="AD">
<input type="submit" onClick="javascript:this.form.code.value=9f" name="rcbtn" value="APP">
<br>
<input type="submit" onClick="javascript:this.form.code.value=72" name="rcbtn" value="Red">
<input type="submit" onClick="javascript:this.form.code.value=71" name="rcbtn" value="Green">
<input type="submit" onClick="javascript:this.form.code.value=63" name="rcbtn" value="Yellow">
<input type="submit" onClick="javascript:this.form.code.value=61" name="rcbtn" value="Blue">
</td>
</tr><tr><td>&nbsp;</td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=20" name="rcbtn" value="TEXT"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=21" name="rcbtn" value="T.OPT"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=39" name="rcbtn" value="SUBTITLE"></td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=b1" name="rcbtn" value="STOP"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=b0" name="rcbtn" value="PLAY"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=ba" name="rcbtn" value="PAUSE"></td>
</tr><tr>
<td colspan=2 align=right><input type="submit" onClick="javascript:this.form.code.value=8f" name="rcbtn" value="Rewind"></td>
<td align=center><input type="submit" onClick="javascript:this.form.code.value=8e" name="rcbtn" value="Forward"></td>
<td><input type="submit" onClick="javascript:this.form.code.value=7e" name="rcbtn" value="Simplink"></td>
</tr></table>
</form>
</div></div>

<div class="post"><div class="posthead">Output (require OPENRELEASE or tmux-pipe)</div><div class="posttext">
<pre><?
	sleep 0.2
	if [ -f /tmp/openrelease.out ]; then tail -n10 /tmp/openrelease.out
	elif [ -f /tmp/RELEASE.out ]; then tail -n10 /tmp/RELEASE.out
	else echo 'Note: require OPENRELEASE or tmux-pipe.'; fi 2>&1
?></pre>
</div></div>

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
