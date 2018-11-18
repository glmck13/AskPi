#!/bin/ksh

ApiKey=73efecd446a34e73aeb663553db2c887

typeset -l Month
typeset -A Categories
Categories+=([events]="On this day in history" [birthdays]="Notable births" [deaths]="Obituaries" [weddings]="Famous weddings")

Caldate=${1:-today}; [ $# -gt 0 ] && shift
Zipcode=${1:-21043}; [ $# -gt 0 ] && shift
Caption=${*:-$Caldate}

Month=$(date -d "$Caldate" +%B )
Day=$(date -d "$Caldate" +%d )
Year=$(date -d "$Caldate" +%Y )

days=$(expr '(' $(date -d "$Caldate" +%s) - $(date +%s) + 86399 ')' / 86400)

Voice=$(shuf -e -n1 Joanna Joey Justin Kendra Kimberly Matthew Salli Nicole Russell Amy Brian Emma)

print "<speak><voice name=$Voice><prosody rate=\"115%\">"

if [ "$days" -lt 0 ]; then
	print "The wait is over for: $Caption. Be sure to celebrate the anniversary on $Month $Day next year!"
	exit
fi

if [ "$days" -le 0 ]; then
	print "Today is the day $Caption."
else
	print "There are $days days left until $Caption."
fi

MidSecs=$(date -d "$Caldate" +%s); let LoSecs=$MidSecs-86400; let HiSecs=$MidSecs+86400
LoDay=$(date -d "@$LoSecs" +%d ); HiDay=$(date -d "@$HiSecs" +%d )
LoMonth=$(date -d "@$LoSecs" +%m ); HiMonth=$(date -d "@$HiSecs" +%m )
LoYear=$(date -d "@$LoSecs" +%Y ); HiYear=$(date -d "@$HiSecs" +%Y )

curl -s "https://weatherplanner.azure-api.net/v1/Forecast/$Zipcode/$LoMonth/$LoDay/$LoYear/$HiMonth/$HiDay/$HiYear" -H "Ocp-Apim-Subscription-Key: $ApiKey" | while IFS=" :," read tag val
do
	tag=${tag//\"/} val=${val//\"/} val=${val//,/}

	case $tag in

	location)
		if [ "$Caldate" ]; then
			print $val | read City State x
			print "Extended forecast for $City, $State on $Caldate:"
		fi
		Caldate=""
		;;
	date)
		Weekday=$(date -d "$val" +%A)
		;;
	max_temp_low)
		HighTemp=$val
		;;
	precipitation)
		Precip=$val
		;;
	temp)
		Temp=$val
		print "$Weekday... $Temp, $Precip, high around $HighTemp."
		;;
	esac
done

for c in events birthdays deaths weddings
do
	curl -s https://www.onthisday.com/$c/$Month/$Day | grep event-list__item | sed -e "s/<script.*script>//g" -e "s/<[^>]*>//g" | shuf -n1 | recode -f html..ascii | sed -e "s/ /... /" -e "s/ \& / and /g" -e "s/^/${Categories[$c]} /" -e "s/$/.../"
done

print "</prosody></voice></speak>"
