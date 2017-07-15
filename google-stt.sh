#!/bin/ksh

PATH=$PWD:$PATH

JsonReq=$(mktemp -t google-jsonreq.XXXXXX)
JsonRsp=$(mktemp -t google-jsonrsp.XXXXXX)

cat - >$JsonReq <<-EOF
{
"config": {
"languageCode": "en-US"
},
"audio": {
"content":"$(base64 -w 0)"
}
}
EOF

curl -s -X POST -H "Content-Type: application/json" --data-binary @$JsonReq \
	"https://speech.googleapis.com/v1/speech:recognize?key=${GOOGLE_APIKEY:?}" >$JsonRsp

grep -m1 '"transcript"' $JsonRsp | sed -e 's/ *"[^"]*" *: *"\([^"]*\)".*/\1/'

rm -f $JsonReq $JsonRsp
