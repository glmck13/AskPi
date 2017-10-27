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

Response="Message sent."

urlencode -d "SPEECH $Trigger $Enum" >$FIFO

cat - <<-EOF
Content-type: text/html

<html>
<body>$Response</body>
</html>
EOF
