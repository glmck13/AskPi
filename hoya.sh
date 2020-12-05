#!/bin/ksh

typeset -l Request Var
Request=$1

case $Request in

game)
	comptail=200 hidetail=75
	print "<p>Here are details about our next game: \\c"
	echo -n $(curl -s "https://guhoyas.com/sports/mens-basketball/schedule" | grep -A$comptail sidearm-schedule-game-completed | grep -A$hidetail Hide | tail -$hidetail | recode -f html..ascii | sed -e "s/<[^>]*>//g" -e "s/*//g" -e "s/ vs/versus/" -e "s/Live//" -e "s/Stats//" -e "s/Tickets//" -e "s/Preview//" | tr -c "[:print:]" " ")
	print "</p>"
	;;

recap|notes)
	outfile="/tmp/$Request$$.html"
	url=$(curl -s "https://guhoyas.com/sports/mens-basketball/schedule" | grep -i recap | tail -1 | sed -e 's/.*href="\([^"]*\)".*/\1/')
	url+="?print=true"
	curl -s "https://guhoyas.com/$url" >$outfile
	ed "$outfile" <<-"EOF" >/dev/null 2>&1
		$
		?<strong>?+2
		.,$d
		w
		q
	EOF
	print "<p>$(recode -f html..ascii <$outfile | sed -e "s/<[^>]*>/ /g" -e "s-//-,-g" -e "s/\[//g" -e "s/\]//g" | tr -c "[:print:]" " " | sed -e "s/ \+/ /g" -e "s/\([A-Z][A-Z ]\+ \)/- \1 - /g" | cut -c1-7990)</p>"
	rm -f "$outfile"
	;;

*)
	print "<p>You said: $Request. I don't understand that!</p>"
	;;
esac
