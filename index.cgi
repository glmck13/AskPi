#!/bin/ksh

PATH=$PWD:$PATH

NEXTWAV=nextwav.cfg DATAFILE=assist.dat

nextwav=$(<$NEXTWAV); (( nextwav = ++nextwav % 10 )); print $nextwav >$NEXTWAV

TMPWAV=./tmp/audio$nextwav.wav; rm -f $TMPWAV

exec 2>&1

typeset -l Speech LastWord Announce

[ "$REQUEST_METHOD" = "POST" ] && read -r QUERY_STRING

vars="$QUERY_STRING"
[ "$HTTP_COOKIE" ] && vars="${vars}&${HTTP_COOKIE}"
while [ "$vars" ]
do
	print $vars | IFS='&' read v vars
	[ "$v" ] && export $v
done

LastWord=$(urlencode -d "$LastWord") lastword=""
Speech=$(urlencode -d "$Speech")
Response=""
Html=""
Match="n"

if [ "$Speech" ]; then

	while read line
	do
		Token=${line:0:1} Pattern=${line#?}

		if [ "$Token" = "#" ]; then
			;

		elif [ "$Token" = "=" ]; then
			expr "$Speech" : "$Pattern" >/dev/null && Match="y"

		elif [ "$Token" = "+" ]; then
			expr "$LastWord $Speech" : "$Pattern" >/dev/null && Match="y"

		elif [ "$Match" != "y" ]; then
			;

		elif [ "$Token" = "~" ]; then
			lastword=$(eval print \""$Pattern"\")

		elif [ "$Token" = "!" ]; then
			eval "$Pattern"

		elif [ "$Token" = "." ]; then
			break

		elif [ "$Token" = "'" ]; then
			Html+=$(eval print \""$Pattern"\")

		else
			Response+=" "
			Response+=$(eval print "$line")
		fi

	done <$DATAFILE
fi

[ "$Response" ] && pico2wave -l en-US -w $TMPWAV "<volume level='40'>$Response"
[ "$Announce" = "y" -a -f $TMPWAV ] && aplay $TMPWAV 2>/dev/null

typeset -A AnnounceButton
AnnounceButton["y"]="" AnnounceButton["n"]=""
AnnounceButton[${Announce:-n}]="checked"

cat - <<EOF
Content-type: text/html
Set-Cookie: LastWord=$(urlencode "${lastword:-$Speech}")

<html>
<head>
<meta name="viewport" content="width=device-width">
</head>

<body>
<form action="$SCRIPT_NAME" method="post">
	Enter your message:
	<br><textarea rows=8 cols=40 name="Speech" /></textarea>
	<br>Announce:
	<input type="radio" name="Announce" value="y" ${AnnounceButton["y"]} />Y
	<input type="radio" name="Announce" value="n" ${AnnounceButton["n"]} />N
	<br><input type="submit" name="Command" value="Submit" />
</form>
EOF

[ -f $TMPWAV ] && cat - <<EOF

<audio controls>
<source src="${SCRIPT_NAME%$(basename $SCRIPT_NAME)}$TMPWAV" type="audio/wav">
</audio> 
EOF

[ "$Response" ] && cat - <<EOF
<p>$Response</p>
EOF

[ "$Html" ] && cat - <<EOF
<p>$Html</p>
EOF

cat - <<EOF

</body>
</html>
EOF
