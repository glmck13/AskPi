#!/bin/ksh

typeset -l Request Var
Request=$1

case $Request in
	*notes*)
		Request="notes";;
	*quotes*)
		Request="quotes";;
	*press*|*conference*|*post*)
		Request="presser";;
	*game*)
		Request="game";;
	*pardon*|*my*take*)
		Request="pardon-my-take";;
	*)
		Request="presser";;
esac

case $Request in

game)
	print "<p>Here are details about our next game: \\c"
	curl -s 'http://www.goduke.com/SportSelect.dbml?&DB_OEM_ID=4200&SPID=1845&SPSID=22726' | grep __INITIAL_STATE__ | tr '{' '\n' | grep "^.id.:.*winLoss.:\"\",.*scoreInfo.:\"\"," | head -1 | sed -e "s/\",/&~/g" | tr '~' '\n' | grep -E "opponent.:|date.:|time.:|location.:" | tr -d '\n'
	print "</p>"
	;;

notes|quotes)
	if [ "$Request" = "notes" ]; then
		Key=11
	elif [ "$Request" = "quotes" ]; then
		Key=12
	fi

	Pdf=$(curl -s 'http://www.goduke.com/SportSelect.dbml?&DB_OEM_ID=4200&SPID=1845&SPSID=22726' | grep __INITIAL_STATE__ | tr '{' '\n' | grep -E "key.:$Key" | tail -1 | sed -e "s/.*url.:.//" -e "s/.,.*//")

	print "<p>\\c"
	if [ "$Pdf" ]; then
		curl -s $Pdf >/tmp/$Request$$.pdf
		pdftotext -enc ASCII7 /tmp/$Request$$.pdf - |
			tr -c "[:print:]" " " |
			sed -e "s/ \+/ /g" -e "s-//-,-g" -e "s/\[//g" -e "s/\]//g" -e "s/\* /\.\.\. /g" | cut -c1-7990
		rm -f /tmp/$Request$$.pdf
	else
		print "No $Request found for ${Opponent:-Opponent} on ${Date:-Date}\\c"
	fi
	print "</p>"
	;;

presser)
	curl -sL https://tunein.com/station/?stationId=230308 |
		grep -o "[^,;>]*[,;>]" |
		grep -E '"title"|"playUrl"' |
		sed -e "s/[^:]*://" -e 's/"//g' -e "s/(.*)//g" -e "s?.u002F?/?g" -e "s/,//g" |
		grep -B1 "\.mp3" | head -2 | tr "\n" "|" | IFS="|" read Opponent Url
		print "<p>$Opponent</p>"
		print "<audio controls><source src=$Url></audio>"
	;;

pardon-my-take)
	curl -sk https://mckspot.dyndns.org:8443/cdn/mkpardonmytake.cgi >/dev/null
	print "<p>Accessing Pardon My Take...</p>"
	print "<audio controls><source src="https://mckspot.dyndns.org:8443/cdn/pardonmytake.m3u"></audio>"
	;;

esac
