#!/bin/ksh

typeset -A Blog
Blog+=([Mon]="mon" [Tue]="tues" [Wed]="wed" [Thu]="thurs" [Fri]="fri" [Sat]="sat")

Caldate=${1:-tomorrow}

Dow=$(date -d "$Caldate" "+%a")

if [ "${Blog[$Dow]}" ]; then
	curl -s https://12labourscrossfit.com/blog/wod-blog/${Blog[$Dow]}-fitness | grep -i "div.*blockinnercontent.*/div" | recode -f html..ascii | sed -e "s/<[^>]*>/ /g"
fi
