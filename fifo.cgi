#!/bin/ksh

PATH=$PWD:$PATH

FIFO=askpi.fifo

[ "$REQUEST_METHOD" = "POST" ] && read -r QUERY_STRING

vars="$QUERY_STRING"
while [ "$vars" ]
do
	print $vars | IFS='&' read v vars
	[ "$v" ] && export $v
done

if [ "$Speech$Trigger$Enum" ]; then
	urlencode -d "SPEECH $Speech $Trigger $Enum" >$FIFO
	Response="Message sent"
fi

cat - <<-EOF
Content-type: text/html

<html>
<head>
<meta name="viewport" content="width=device-width">
</head>

<body>
<form action="$SCRIPT_NAME" method="post">
	Enter your message:
	<br><textarea rows=8 cols=40 name="Speech" /></textarea>
	<br><input type="submit" name="Command" value="Submit" />
</form>
EOF

[ "$Response" ] && cat - <<EOF
<p>$Response</p>
EOF

cat - <<EOF
</body>
</html>
EOF
