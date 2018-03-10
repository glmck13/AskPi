#!/bin/ksh

Number=${1:-23}

print "Psalm $Number:"

curl -s http://www.usccb.org/bible/psalms/$Number | grep 'class=.po' | sed -e "s/<span.*span>//" -e "s/<sup.*sup>//" -e "s/<[^>]*>//g" | recode -f html..ascii
