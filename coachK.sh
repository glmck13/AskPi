#!/bin/ksh

curl -sL https://tunein.com/station/?stationId=230308 |
	grep -o "[^,;>]*[,;>]" |
	grep -E '"title"|"playUrl"' |
	sed -e "s/[^:]*://" -e 's/"//g' -e "s/(.*)//g" -e "s?.u002F?/?g" |
	grep -B1 "\.mp3"
