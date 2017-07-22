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

	Stop*|Start*)
		uid=$(id -nu)
		pids=$(pgrep -u $uid -x apache2 -d'|'); pids+="|$$"
		pids=$(pgrep -u $uid | egrep -v "$pids")
		[ "$pids" ] && kill $pids >/dev/null 2>&1
		if [[ $Command == Start* ]]; then
			for v in ItagAddr Keywords Display
			do
				export $v="$(eval urlencode -d '$'$v)"
			done
			sphinx.sh >/dev/null 2>&1 &
			itag.sh >/dev/null 2>&1 &
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
<td>
Configfile:<br>
<input type="text" size=15 name="Configfile" value="$Configfile">
</td>
<td>
<input type="submit" name="Command" value="Display" /><br>
<input type="submit" name="Command" value="Save" /><br>
<input type="submit" name="Command" value="Delete" /><br>
</td>

<td>
ItagAddr:<br>
<input type="text" size=15 name="ItagAddr"><br>
Keywords:<br>
<input type="text" size=15 name="Keywords"><br>
Display:<br>
<input type="text" size=15 name="Display">
</td>
<td>
<input type="submit" name="Command" value="Stop Voice Service" /><br>
<input type="submit" name="Command" value="Start Voice Service" />
</td>
</tr>

</table>
</form>
<pre>
$(if [ "$ExecCmd" ]; then; eval $ExecCmd; fi)
</pre>

</html>
EOF
