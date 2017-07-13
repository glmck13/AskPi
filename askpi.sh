#!/bin/ksh

PATH=$PWD:$PATH
APIKEY=""
FIFO=askpi.fifo
COOKIES=./tmp/cookies.txt; >$COOKIES
SPEECH=./tmp/google.wav
JSONREQ=./tmp/google.txt
JSONRSP=./tmp/google.log

exec <>$FIFO

while true
do
	read cmd <$FIFO

	case "$cmd" in

	CONNECT*)
		# DTMF
		# play -n -r 16k synth 0.5 sine 941 sine 1477 remix - 2>/dev/null
		;;

	DISCONNECT*)
		# Busy signal
		# play -n -r 16k synth 0.5 sine 480 sine 620 sine 480 sine 620 sine 480 sine 620 delay 0 0 1 1 2 2 remix - 2>/dev/null
		;;

	BATTERY*)
		Banner="${cmd#* }"
		;;

	LISTEN*)
		while true
		do
			# Dial tone
			# play -n -r 16k synth 1 sine 350 sine 440 remix - 2>/dev/null
			play -n -r 16k synth 0.5 sine 480 sine 620 remix - 2>/dev/null

			# rec -r 16k -c 1 $SPEECH noiseprof noise
			# timeout 3s rec -r 16k -c 1 $SPEECH noisered noise vol 5 2>/dev/null
			timeout 3s rec -r 16k -c 1 $SPEECH vol 5 2>/dev/null
			# [ "$?" -eq 124 ] && break

			cat - >$JSONREQ <<-EOF
			{
				"config": {
					"languageCode": "en-US"
				},
				"audio": {
					"content":"$(base64 $SPEECH -w 0)"
				}
			}
			EOF

			curl -s -X POST -H "Content-Type: application/json" --data-binary @$JSONREQ \
				"https://speech.googleapis.com/v1/speech:recognize?key=${APIKEY}" >$JSONRSP

			Speech=$(grep -m1 '"transcript"' $JSONRSP | sed -e 's/ *"[^"]*" *: *"\([^"]*\)".*/\1/')

			curl -s --data-urlencode "Speech=$Speech" --data "Banner=$Banner" \
				http://localhost -b $COOKIES -c $COOKIES |
				grep -E "src|href" | sed -e "s/src=/url=/" -e "s/href=/url=/" \
				-e "s/.*url=\([^ ]*\).*/\1/" -e 's/"//g' | while read url
			do
				url=${url#/}

				[[ "$url" == http:* || "$url" == https:* ]] || url="http://localhost/${url}"

				case "$url" in

				*.wav)
					play "$url" 2>/dev/null
					;;

				*.mp3)
					mpg123 "$url" 2>/dev/null
					;;

				*.mp4)
					omxplayer -o alsa:plughw:Device "$url" 2>/dev/null
					;;

				*youtube*)
					omxplayer -o alsa:plughw:Device $(youtube-dl -g -f best "$url") 2>/dev/null
					;;

				*)
					firefox "$url"
					;;
				esac
			done

			lastword=$(grep LastWord $COOKIES) lastword=${lastword#*LastWord?}

			[ ! "$lastword" -o "$lastword" = "nil" ] && break
		done
		;;
	esac
done
