#!/usr/bin/haserl
content-type: text/html

<? cat /var/www/cgi-bin/header.inc ?><p class="largefont">LGMOD CONFIGURATION / RELEASE (careful!)</p><div class="pagebody">

<div class="post"><div class="posthead">RELEASE OUT (require OPENRELEASE or tmux-pipe)</div><div class="posttext">
<pre><?
send=''; orel='' tmux=''
if [ -n "$FORM_CR" ]; then orel="$orel"$'\n'; tmux="$tmux C-m"
fi
if  [ -n "$FORM_Send" ]; then send="$FORM_release"
elif [ -n "$FORM_F1" ];  then orel=$'\x1b''[11~'; tmux='F1'
elif [ -n "$FORM_F2" ];  then orel=$'\x1b''[12~'; tmux='F2'
elif [ -n "$FORM_F3" ];  then orel=$'\x1b''[13~'; tmux='F3'
elif [ -n "$FORM_F4" ];  then orel=$'\x1b''[14~'; tmux='F4'
elif [ -n "$FORM_F5" ];  then orel=$'\x1b''[15~'; tmux='F5'
elif [ -n "$FORM_F6" ];  then orel=$'\x1b''[17~'; tmux='F6'
elif [ -n "$FORM_F7" ];  then orel=$'\x1b''[18~'; tmux='F7'
elif [ -n "$FORM_F8" ];  then orel=$'\x1b''[19~'; tmux='F8'
elif [ -n "$FORM_F9" ];  then orel=$'\x1b''[20~'; tmux='F9'
elif [ -n "$FORM_F10" ]; then orel=$'\x1b''[21~'; tmux='F10'
elif [ -n "$FORM_F11" ]; then orel=$'\x1b''[22~'; tmux='F11'
elif [ -n "$FORM_F12" ]; then orel=$'\x1b''[23~'; tmux='F12'
elif [ -n "$FORM_ESC" ]; then orel=$'\x1b'; tmux='ESCAPE'
elif [ -n "$FORM_hot" ]; then send="$FORM_hot"; orel=''; tmux=''
elif [ -n "$FORM_cut" ]; then send="$FORM_cut"; # no "enter"
fi
if [ -n "$send$orel$tmux" ]; then
	out=$(if [ -e /tmp/openrelease.in ]; then
			[ -n "$send" ] && echo -n "$send" > /tmp/openrelease.in
			[ -n "$orel" ] && echo -n "$orel" > /tmp/openrelease.in
		else
			[ -n "$send" ] && tmux send-keys -t RELEASE "$send"
			[ -n "$tmux" ] && tmux send-keys -t RELEASE $tmux
		fi 2>&1)
fi

sleep 0.2
if [ -f /tmp/openrelease.out ]; then tail -n100 /tmp/openrelease.out; # | /home/lgmod/ansi2html.sh
elif [ -f /tmp/RELEASE.out ]; then tail -n100 /tmp/RELEASE.out; # | /home/lgmod/ansi2html.sh
else echo 'Note: require OPENRELEASE or tmux-pipe.'; fi 2>&1

if [ -n "$send$orel$tmux" ]; then
	[ -e /tmp/openrelease.in ] && tmux='' || orel=''
	echo; echo "<b>Sent: $send $orel$tmux"
	if [ -n "$out" ]; then
		echo "Output: $out"
		echo 'Note: require OPENRELEASE or tmux'
	fi; echo -n '</b>'
fi
?></pre>
</div></div>

<div class="post"><div class="posthead">RELEASE IN (require OPENRELEASE or tmux)</div><div class="posttext">
<b>Note: Switch back to "production mode" before using "Remote" page.</b><br><br>
<form action="release.cgi#goto_bottom" method="post">
<input name="release" type="text" size=48>
<input type="submit" name="Send" value="Send">
<input name="CR" type="checkbox" value="1" checked><b>&lt;enter&gt;</b>
<br>
<input type="submit" name="F1" value="F1"> <input type="submit" name="F2" value="F2">
<input type="submit" name="F3" value="F3"> <input type="submit" name="F4" value="F4">
<input type="submit" name="F5" value="F5"> <input type="submit" name="F6" value="F6">
<input type="submit" name="F7" value="F7"> <input type="submit" name="F8" value="F8">
<input type="submit" name="F9" value="F9"> <input type="submit" name="F10" value="F10">
<input type="submit" name="F11" value="F11"> <input type="submit" name="F12" value="F12">
<input type="submit" name="ESC" value="ESC">
<br>
<input type="submit" name="cut" value="ke 01 00"> <input type="submit" name="cut" value="ke 01 01">
<input type="submit" name="cut" value="debug"> <input type="submit" name="cut" value="d">
<input type="submit" name="hot" value="u">_ <input type="submit" name="hot" value="x">_
<input type="submit" name="hot" value="K">_ <input type="submit" name="hot" value="L">_
<input type="submit" name="cut" value="99"> <input type="submit" name="cut" value="ff">
<input type="submit" name="cut" value="exit">
<br>
<b> pass:</b><input type="submit" name="cut" value="<? MODEL=$(echo /lg/user/model.*); MODEL="${MODEL#*model.}"; echo -n 'd '"${MODEL}"'elqjrm' ?>">_
<!-- <b> games:</b><input type="submit" name="cut" value="call UI_CONTENTSLINK_CreateWindow">_ -->
</form><a name='goto_bottom'></a>
</div></div>

</div></div>
</div>
<br>
<? cat /var/www/cgi-bin/footer.inc ?>
