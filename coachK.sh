#!/bin/ksh

typeset -l Request Var
Request=$1

case $Request in

game)
	comptail=200 hidetail=75
	print "<p>Here are details about our next game: \\c"
	echo -n $(curl -s https://goduke.com/sports/mens-basketball/schedule | grep -A$comptail sidearm-schedule-game-completed | grep -A$hidetail Hide | tail -$hidetail | egrep "<span|<img" | sed -e "s/.*alt=.//" -e "s/ Logo.*//" -e "s/<[^>]*>//g" -e "s/*//g" -e "s/TV://" -e "s/ vs//" | tr -c "[:print:]" " ")
	print "</p>"
	;;

notes|quotes)
	if [ "$Request" = "notes" ]; then
		search=Notes.pdf tail=1
	else
		search=Quotes.pdf tail=2
	fi

	print "<p>\\c"
	curl -s https://goduke.com/sports/mens-basketball/schedule | grep "href.*$search" | tail -$tail | sed -e 's/.*href="\([^"]*\)".*/\1/' -e "s-//-/-g" | while read pdf
	do
		curl -s https://s3.amazonaws.com/goduke.com$pdf >/tmp/$Request$$.pdf
		pdftotext -enc ASCII7 /tmp/$Request$$.pdf -
	done | sed -e 's/"//g' -e "s/ \+/ /g" -e "s-//-,-g" -e "s/\[//g" -e "s/\]//g" -e "s/\* /\.\.\. /g" | tr -c "[:print:]" " " | cut -c1-5000
	print "</p>"
	rm -f /tmp/$Request$$.pdf
	;;

esac
