#!/bin/ksh

curl -s 'http://hosted.ap.org/dynamic/fronts/HOME?SITE=AP&SECTION=HOME' | grep apHeadline |
	sed -e "s/<[^>]*>/. /g" -e "s/\&quot;/\"/g" -e "s/\&apos;/\'/g" -e "s/ \.//g" -e "s/^. //"
