#!/bin/ksh

PATH=$PWD:$PATH

DATAFILE=assist.dat

read -r QUERY_STRING

vars="$QUERY_STRING"
[ "$HTTP_COOKIE" ] && vars="${vars}&${HTTP_COOKIE}"
while [ "$vars" ]
do
	print $vars | IFS='&' read v vars
	[ "$v" ] && export $v
done

case "$Command" in
	Save)
		if [ "$Configfile" ]; then
			urlencode -d $Contents | tr -d "\r" >$Configfile
		fi
		;;

	Delete)
		[ "$Configfile" != $DATAFILE ] && rm -f $Configfile
		;;

	Stop*)
		kill -HUP -1
		;;

	Start*)
		itag.sh >/dev/null 2>&1 &
		askpi.sh >/dev/null 2>&1 &
		;;
esac

cat - <<EOF
Content-type: text/html

<html>

<form action="$SCRIPT_NAME" method="post">

<br><textarea rows=25 cols=100 name="Contents" />
$([ -f "$Configfile" ] && cat $Configfile)
</textarea>

<br>Files on disk: $(ls *.dat)
<br>Configfile: <input type="text" size=20 name="Configfile" value="$Configfile">
<input type="submit" name="Command" value="Display" />
<input type="submit" name="Command" value="Save" />
<input type="submit" name="Command" value="Delete" />
<br>
<input type="submit" name="Command" value="Stop Voice Service" />
<input type="submit" name="Command" value="Start Voice Service" />
</form>

</html>
EOF
