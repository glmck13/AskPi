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
esac

cat - <<EOF
Content-type: text/html

<html>

<form action="$SCRIPT_NAME" method="post">

<br><textarea rows=40 cols=100 name="Contents" />
$([ -f "$Configfile" ] && cat $Configfile)
</textarea>

<br>Files on disk: $(ls *.dat)
<br>Configfile: <input type="text" size=20 name="Configfile" value="$Configfile">
<input type="submit" name="Command" value="Display" />
<input type="submit" name="Command" value="Save" />
<input type="submit" name="Command" value="Delete" />
</form>

</html>
EOF
