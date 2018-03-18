#!/bin/ksh

curl -s http://feeds.reuters.com/reuters/topNews |
	grep -E '.<title>|.<description>' |
	sed -e "s/<[^>]*>/ - /g" -e "s/\&[gl]t.*//" -e "s/\&amp;/\&/g" -e "s/\([A-Z]\)\./\1/g" | tr -c "[:print:]" " " | cut -c1-7990
