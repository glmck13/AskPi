#!/bin/ksh

typeset -l Request Var
Request=$1

case $Request in

game)
	comptail=200 hidetail=80
	print "<p>Here are details about our next game: \\c"
	echo -n $(curl -s http://www.guhoyas.com/sports/mens-basketball/schedule | grep -A$comptail sidearm-schedule-game-completed | grep -A$hidetail Hide | tail -$hidetail | egrep "<span|<img" | recode -f html..ascii | sed -e "s/<[^>]*>//g" -e "s/Radio://" -e "s/ vs//" | tr -c "[:print:]" " ")
	print "</p>"
	;;

recap)
	outfile="/tmp/$Request$$.html"
	url=$(curl -s http://www.guhoyas.com/sports/mens-basketball/schedule | grep -i recap | tail -1 | sed -e 's/.*href="\([^"]*\)".*/\1/')
	curl -s http://www.guhoyas.com/$url >$outfile
	ed "$outfile" <<-"EOF" >/dev/null 2>&1
		/<strong>/-1
		1,.d
		$
		?<strong>?+2
		.,$d
		w
		q
	EOF
	print "<p>$(recode -f html..ascii <$outfile | sed -e "s/<[^>]*>//g" -e "s-//-,-g" -e "s/\[//g" -e "s/\]//g" | tr -c "[:print:]" " " | sed -e "s/ \+/ /g" -e "s/\([A-Z][A-Z ]\+ \)/- \1 - /g" | cut -c1-7990)</p>"
	rm -f "$outfile"
	;;

esac
