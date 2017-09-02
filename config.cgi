#!/bin/ksh

PATH=$PWD:$PATH

SETTINGS=askpi.conf
DATAFILE=assist.dat

[ "$REQUEST_METHOD" = "POST" ] && read -r QUERY_STRING

vars="$QUERY_STRING"
[ "$HTTP_COOKIE" ] && vars="${vars}&${HTTP_COOKIE}"
while [ "$vars" ]
do
	print $vars | IFS='&' read v vars
	[ "$v" ] && export $v
done

. $SETTINGS; rm -f $SETTINGS
for v in ItagAddr Keywords Display
do
	export $v="$(eval urlencode -d '$'${v})"
	[ ! "$(eval print '$'${v})" ] && export $v=$(eval print '$'${v}_SAVE)
	export ${v}_SAVE=$(eval print '$'${v})
	print ${v}_SAVE=\"$(eval print '$'${v}_SAVE)\" >>$SETTINGS
done
chmod +x $SETTINGS

case "$Command" in
	Save)
		if [ "$Configfile" ]; then
			urlencode -d $Contents | tr -d "\r" >$Configfile
		fi
		;;

	Delete)
		[ "$Configfile" != $DATAFILE ] && rm -f $Configfile
		;;

	Stop*|Start*)
		uid=$(id -nu)
		pids=$(pgrep -u $uid -x apache2 -d'|'); pids+="|$$"
		pids=$(pgrep -u $uid | egrep -v "$pids")
		[ "$pids" ] && kill $pids >/dev/null 2>&1
		if [[ $Command == Start* ]]; then
			sphinx.sh >/dev/null 2>&1 &
			itag.sh >/dev/null 2>&1 &
			ir.sh >/dev/null 2>&1 &
			askpi.sh >/dev/null 2>&1 &
		fi
		ExecCmd="ps -fu $uid"
		;;
esac

cat - <<EOF
Content-type: text/html

<html>

<form action="$SCRIPT_NAME" method="post">

<br><textarea rows=25 cols=100 name="Contents" />
$([ -f "$Configfile" ] && cat $Configfile)
</textarea>

<style>
  table, th, td {
    border: 1px solid;
  }
</style>

<br>Files on disk: $(ls *.dat)
<table>

<tr>
<th colspan=2>Config File</th>
<th colspan=2>Voice Service</th>
</tr>

<tr>
<td>
<input type="text" size=15 name="Configfile" value="$Configfile">
</td>
<td>
<input type="submit" name="Command" value="Display" /><br>
<input type="submit" name="Command" value="Save" /><br>
<input type="submit" name="Command" value="Delete" /><br>
</td>

<td>
ItagAddr:<br>
<input type="text" size=15 name="ItagAddr" value="$ItagAddr"><br>
Keywords:<br>
<input type="text" size=15 name="Keywords" value="$Keywords"><br>
Display:<br>
<input type="text" size=15 name="Display" value="$Display">
</td>
<td>
<input type="submit" name="Command" value="Stop" /><br>
<input type="submit" name="Command" value="Start" />
</td>
</tr>

</table>
</form>
<pre>
$(if [ "$ExecCmd" ]; then; eval $ExecCmd; fi)
</pre>

</html>
EOF
