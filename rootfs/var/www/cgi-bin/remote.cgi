#!/usr/bin/haserl
content-type: text/html

<? /usr/bin/haserl /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / REMOTE</p><div class="pagebody">

<? if [ -n "$FORM_code" ]; then
	echo "Code: $FORM_code"
	out=$(if [ -e /tmp/openrelease.in ]; then echo "mc 01 $FORM_code" > /tmp/openrelease.in
		else tmux send-keys -t RELEASE "mc 01 $FORM_code" C-m
		fi 2>&1)
	if [ -n "$out" ]; then
		echo "<pre>Error: $out"
		echo 'Note: This page require tmux or OPENRELEASE mode.</pre>'
	else
		echo '<script language="javascript" type="text/javascript">history.back();</script>'
		exit
	fi
fi ?>
<div class="post"><div class="posthead">REMOTE - require tmux or OPENRELEASE mode</div><div class="posttext" align="center">
<br>
<form action="remote.cgi" method="post"><input type="hidden" name="code" value="">
<input type="submit" onClick="javascript:this.form.code.value=08" name="power" value="POWER">
<br>
<input type="submit" onClick="javascript:this.form.code.value=95" name="rcbtn" value="ENERGY">
<input type="submit" onClick="javascript:this.form.code.value=30" name="rcbtn" value="A / V">
<input type="submit" onClick="javascript:this.form.code.value=0b" name="input" value="INPUT">
<input type="submit" onClick="javascript:this.form.code.value=f0" name="rcbtn" value="TV/RAD">
<br>
<input type="submit" onClick="javascript:this.form.code.value=c8" name="usb"   value="USB">
<input type="submit" onClick="javascript:this.form.code.value=''" name="comp1" value="COMP1 ?">
<input type="submit" onClick="javascript:this.form.code.value=''" name="tv"    value="TV ?">
<input type="submit" onClick="javascript:this.form.code.value=''" name="hdmi1" value="HDMI1 ?">
<input type="submit" onClick="javascript:this.form.code.value=''" name="hdmi2" value="HDMI2 ?">
<br>
<br>
<input type="submit" onClick="javascript:this.form.code.value=11" name="1" value="1">
<input type="submit" onClick="javascript:this.form.code.value=12" name="2" value="2">
<input type="submit" onClick="javascript:this.form.code.value=13" name="3" value="3">
<br>
<input type="submit" onClick="javascript:this.form.code.value=14" name="4" value="4">
<input type="submit" onClick="javascript:this.form.code.value=15" name="5" value="5">
<input type="submit" onClick="javascript:this.form.code.value=16" name="6" value="6">
<br>
<input type="submit" onClick="javascript:this.form.code.value=17" name="7" value="7">
<input type="submit" onClick="javascript:this.form.code.value=18" name="8" value="8">
<input type="submit" onClick="javascript:this.form.code.value=19" name="9" value="9">
<br>
<input type="submit" onClick="javascript:this.form.code.value=53" name="list"   value="LIST">
<input type="submit" onClick="javascript:this.form.code.value=00" name="0"      value="0">
<input type="submit" onClick="javascript:this.form.code.value=1a" name="q_view" value="Q.VIEW">
<br>
<br>
<input type="submit" onClick="javascript:this.form.code.value=02" name="vol_up" value="VOL+">
<input type="submit" onClick="javascript:this.form.code.value=1e" name="fav"    value="FAV">
<input type="submit" onClick="javascript:this.form.code.value=00" name="pr_up"  value="PR+">
<br>
<b>VOL</b>&nbsp;&nbsp;
<input type="submit" onClick="javascript:this.form.code.value=79" name="ratio" value="RATIO">
&nbsp;&nbsp;<b>PRG</b>
<br>
<input type="submit" onClick="javascript:this.form.code.value=03" name="vol_down" value="VOL-">
<input type="submit" onClick="javascript:this.form.code.value=09" name="mute"     value="MUTE">
<input type="submit" onClick="javascript:this.form.code.value=01" name="pr_down"  value="PR-">
<br>
<br>
<input type="submit" onClick="javascript:this.form.code.value=43" name="rcbtn" value="MENU">
<input type="submit" onClick="javascript:this.form.code.value=ab" name="rcbtn" value="GUIDE (S7)">
<input type="submit" onClick="javascript:this.form.code.value=59" name="rcbtn" value="NETCAST (BCM)">
<input type="submit" onClick="javascript:this.form.code.value=45" name="rcbtn" value="Q.MENU">
<br>
<input type="submit" onClick="javascript:this.form.code.value=40" name="rcbtn" value="UP">
<br>
<input type="submit" onClick="javascript:this.form.code.value=07" name="left"  value="LEFT">
<input type="submit" onClick="javascript:this.form.code.value=44" name="ok"    value="OK">
<input type="submit" onClick="javascript:this.form.code.value=06" name="right" value="RIGHT">
<br>
<input type="submit" onClick="javascript:this.form.code.value=41" name="rcbtn" value="DOWN">
<br>
<input type="submit" onClick="javascript:this.form.code.value=28" name="back"  value="BACK">
<input type="submit" onClick="javascript:this.form.code.value=aa" name="rcbtn" value="INFO (S7)">
<input type="submit" onClick="javascript:this.form.code.value=ab" name="rcbtn" value="GUIDE (BCM)">
<input type="submit" onClick="javascript:this.form.code.value=5b" name="rcbtn" value="EXIT">
<br>
<br>
<input type="submit" onClick="javascript:this.form.code.value=72" name="rcbtn" value="RED">
<input type="submit" onClick="javascript:this.form.code.value=71" name="rcbtn" value="GREEN">
<input type="submit" onClick="javascript:this.form.code.value=63" name="rcbtn" value="YELLOW">
<input type="submit" onClick="javascript:this.form.code.value=61" name="rcbtn" value="BLUE">
<br>
<br>
<input type="submit" onClick="javascript:this.form.code.value=20" name="rcbtn" value="TEXT">
<input type="submit" onClick="javascript:this.form.code.value=21" name="rcbtn" value="T.OPT">
<input type="submit" onClick="javascript:this.form.code.value=39" name="rcbtn" value="SUBTITLE">
<br>
<input type="submit" onClick="javascript:this.form.code.value=b1" name="rcbtn" value="STOP">
<input type="submit" onClick="javascript:this.form.code.value=b0" name="rcbtn" value="PLAY">
<input type="submit" onClick="javascript:this.form.code.value=ba" name="rcbtn" value="PAUSE">
<br>
<input type="submit" onClick="javascript:this.form.code.value=8f" name="rcbtn" value="Rewind">
<input type="submit" onClick="javascript:this.form.code.value=8e" name="rcbtn" value="Forward">
<input type="submit" onClick="javascript:this.form.code.value=7e" name="rcbtn" value="Simplink">
<br>
<br>
<input type="submit" onClick="javascript:this.form.code.value=aa" name="rcbtn" value="INFO (BCM)">
<input type="submit" onClick="javascript:this.form.code.value=91" name="rcbtn" value="AD (BCM)">
<input type="submit" onClick="javascript:this.form.code.value=9f" name="rcbtn" value="APP (BCM)">
</form>
</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
