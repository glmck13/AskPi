#!/bin/ksh

compute_hmac () {
  hash=$(print -n "$2" | openssl dgst -sha256 -mac HMAC -macopt "$1"); print "${hash##* }"
}

PATH=$PWD:$PATH

Speech=$(tr '"\n\t' "   ")

AWS_REGION=us-east-1
AWS_SERVICE=polly
AWS_URL="${AWS_SERVICE}.${AWS_REGION}.amazonaws.com"
API_METHOD=POST
API_URI=/v1/speech
API_EPOCH=$(date "+%s")
API_DATE=$(date -u -d @$API_EPOCH "+%Y%m%d")
API_TIME=$(date -u -d @$API_EPOCH "+%Y%m%dT%H%M%SZ")

JsonReq=$(mktemp -t aws-jsonreq.XXXXXX)
cat - <<-EOF >$JsonReq
	{
	"OutputFormat": "mp3",
	"SampleRate": "16000",
	"Text": "<speak><prosody volume=\"x-loud\">$Speech</prosody></speak>",
	"TextType": "ssml",
	"VoiceId": "${AWS_VOICE:-Matthew}"
	}
EOF

JsonReqHash=$(sha256sum "$JsonReq"); JsonReqHash=${JsonReqHash%% *}

HeaderList="content-type;host;x-amz-date"

CanonicalRequest=$(
	cat - <<-EOF
	$API_METHOD
	$API_URI

	content-type:application/json
	host:${AWS_URL}
	x-amz-date:${API_TIME}

	$HeaderList
	$JsonReqHash
	EOF
)

CanonicalRequestHash=$(sha256sum <(printf "%s" "$CanonicalRequest")); CanonicalRequestHash=${CanonicalRequestHash%% *}

CredentialScope="${API_DATE}/${AWS_REGION}/${AWS_SERVICE}/aws4_request"

StringToSign=$(
	cat - <<-EOF
	AWS4-HMAC-SHA256
	${API_TIME}
	${CredentialScope}
	${CanonicalRequestHash}
	EOF
)

DateKey=$(compute_hmac key:AWS4${AWS_SECRET:?} ${API_DATE})
DateRegionKey=$(compute_hmac hexkey:$DateKey ${AWS_REGION})
DateRegionServiceKey=$(compute_hmac hexkey:$DateRegionKey ${AWS_SERVICE})
SigningKey=$(compute_hmac hexkey:$DateRegionServiceKey "aws4_request")
Signature=$(compute_hmac hexkey:$SigningKey "${StringToSign}")

#curl -s --data-binary @${JsonReq} \
#
# When running curl as a snap, /tmp files aren't accesible between apps!
#
cat $JsonReq | curl -s --data-binary @- \
	-H "Authorization: AWS4-HMAC-SHA256 Credential=${AWS_KEY:?}/${CredentialScope}, SignedHeaders=${HeaderList}, Signature=${Signature}" \
	-H "content-type:application/json" \
	-H "x-amz-date:${API_TIME}" \
	https://${AWS_URL}${API_URI}

rm -f $JsonReq
