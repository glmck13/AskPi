#!/bin/ksh

typeset -l Month
typeset -A Categories
Categories+=([events]="On this day in history" [birthdays]="Born" [deaths]="Died" [weddings]="Married")

Caldate=${1:-today}; [ $# -gt 0 ] && shift
Caption=${*:-$Caldate}

Month=$(date -d "$Caldate" +%B )
Day=$(date -d "$Caldate" +%d )
Year=$(date -d "$Caldate" +%Y )

days=$(expr '(' $(date -d "$Caldate" +%s) - $(date +%s) + 86399 ')' / 86400)
print "There are $days days left until $Caption."

for c in events birthdays deaths weddings
do
	curl -s https://www.onthisday.com/$c/$Month/$Day | grep event-list__item | sed -e "s/<[^>]*>//g" | shuf -n1 | recode html..ascii | sed -e "s/ /: /" -e "s/^/${Categories[$c]} /" -e "s/$/./"
done
