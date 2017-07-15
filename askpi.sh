#!/bin/ksh

PATH=$PWD:$PATH

BROWSER=chromium-browser
ASKPI=http://localhost
FIFO=askpi.fifo
VOICE=$(mktemp -t askpi-voice.XXXXXX)
COOKIES=$(mktemp -t askpi-cookies.XXXXXX); >$COOKIES

trap "rm -f $VOICE $COOKIES; exit" INT HUP QUIT EXIT

. credentials.conf

exec <>$FIFO

while true
do
	read cmd <$FIFO

	case "$cmd" in

	CONNECT*)
		;;

	DISCONNECT*)
		;;

	BATTERY*)
		Banner="${cmd#* }"
		;;

	LISTEN*)
		while true
		do
			play -n -r 16k synth 0.5 sine 480 sine 620 remix - 2>/dev/null

			timeout 3s rec -r 16k -c 1 -t wav $VOICE vol 5 2>/dev/null
			Speech=$(google-stt.sh <$VOICE)

			curl -s --data-urlencode "Speech=$Speech" \
				--data "Banner=$Banner" \
				--data "Announce=t" \
				$ASKPI -b $COOKIES -c $COOKIES | while read html
			do
				if [[ "$html" == @(*src=*|*href=*) ]]; then

				url=$(print "$html" | sed -e "s/src=/url=/" -e "s/href=/url=/" \
					-e "s/.*url=\([^ ]*\).*/\1/" -e 's/"//g')

				url=${url#/}

				[[ "$url" == http:* || "$url" == https:* ]] || url="$ASKPI/${url}"

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
					DISPLAY=:0 $BROWSER "$url" &
					;;
				esac

				elif [[ "$html" == \<p\>*\<?p\> ]]; then

				html=${html#<p>} html=${html%</p>}

				print "$html" | grep -o -E '[^\.]*.' | split -l5 --filter=aws-polly.sh |
					mpg123 - 2>/dev/null

				fi
			done

			lastword=$(grep LastWord $COOKIES) lastword=${lastword#*LastWord?}

			[ ! "$lastword" -o "$lastword" = "nil" ] && break
		done
		;;
	esac
done

rm -f $COOKIES $VOICE
