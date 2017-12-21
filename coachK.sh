#!/bin/ksh

typeset -l Request Var
Request=$1

case $Request in
	*notes*)
		Request="notes";;
	*quotes*)
		Request="quotes";;
	*press*|*conference*|*post*|*game*)
		Request="presser";;
	*)
		Request="presser";;
esac

case $Request in

notes|quotes)

	record="" last=""
	curl -s 'http://www.goduke.com/SportSelect.dbml?&DB_OEM_ID=4200&SPID=1845&SPSID=22726' |
		grep -Ei -A1 "class=.opponent|class=.date_nowrap|notes$|quotes$" |
		grep "^					" |
		sed -e "s/.*HREF=.\(.*\.pdf\).*.>\(.*\)/\1,\2/" -e "s/<[^>]\+>//g" -e "s/\&nbsp;//g" -e "s/	//g" -e "/^$/d" | while read line
	do
		line=${line//\*/}

		case $line in
		???,\ *)
			[[ "$record" == *.pdf* ]] && last=$record
			record=$line
			;;

		*)
			record+="|$line"
		esac
	done

	[[ "$record" == *.pdf* ]] && last=$record

	print "$last" | IFS="|" read Date Opponent pdf1 pdf2
	Var=${pdf1#*,} Val=${pdf1%,*}; eval $Var=$Val
	Var=${pdf2#*,} Val=${pdf2%,*}; eval $Var=$Val

	Pdf=$(eval print \$$Request)

	if [ "$Pdf" ]; then
		curl -s $Pdf >/tmp/$Request$$.pdf
		print "<p>\\c"
		pdftotext -layout -enc ASCII7 /tmp/$Request$$.pdf - | tr -c "[:print:]" " " |
			sed -e "s/ \+/ /g" -e "s-//-,-g" -e "s/\[//g" -e "s/\]//g"
		print "</p>"
		rm -f /tmp/$Request$$.pdf
	else
		print "No $Request found for ${Opponent:-Opponent} on ${Date:-Date}"
	fi
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

esac
