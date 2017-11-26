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

for note in G:0.25 C:0.25 A:0.25 F:0.25 E:0.25 C:0.25 D:0.5 G:0.25 C:0.25 A:0.25 B:0.25 C5:0.25 D5:0.25 C5:0.5
do
	play -n -r 16k synth ${note#*:} pluck ${note%:*} vol 0.1
done

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

	LISTEN*|SPEECH*)
		[ "$PIDS" ] && kill $PIDS 2>/dev/null
		PIDS=""

		while true
		do
			if [[ $cmd == LISTEN* ]]; then
				play -n -r 16k synth 0.1 sine 480 sine 941 delay 0 0.1 remix - 2>/dev/null
				timeout 4s rec -r 16k -c 1 -t wav $VOICE vol 5 2>/dev/null
				Speech=$(google-stt.sh <$VOICE)
			else
				Speech=${cmd#* }
			fi

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
					cmd='play "$url"'
					;;

				*.mp3)
					cmd='mpg123 "$url"'
					;;

				*.mp4)
					cmd='omxplayer -o alsa:plughw:Device "$url"'
					;;

				*youtube*)
					cmd='omxplayer -o alsa:plughw:Device $(youtube-dl -g -f best "$url")'
					;;

				*)
					cmd=''; DISPLAY=${Display:-:0} $BROWSER "$url" &
					;;
				esac

				if [ "$cmd" ]; then
					[ "$PIDS" ] && wait
					eval exec $cmd 2>/dev/null &
					PIDS+=" $!"
				fi

				elif [[ "$html" == \<p\>*\<?p\> ]]; then

				html=${html#<p>} html=${html%</p>}

				[ "$PIDS" ] && wait
				( print "$html" | grep -o -E '[^\.]*.' | split -l5 --filter=aws-polly.sh |
					mpg123 - 2>/dev/null ) &
				PIDS+=" $!"

				fi
			done

			lastword=$(grep LastWord $COOKIES) lastword=${lastword#*LastWord?}

			[ ! "$lastword" -o "$lastword" = "nil" ] && break
		done
		;;
	esac
done

rm -f $COOKIES $VOICE
