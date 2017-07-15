#!/bin/ksh

curl -s http://feeds.reuters.com/reuters/topNews | grep '.<description>' |
	sed -e "s/<description>//g" -e "s/\&[gl]t.*//" -e "s/\&amp;/\&/g" -e "s/\([A-Z]\)\./\1/g"
