#!/bin/ksh

PATH=$PWD:$PATH

KEYWORDS=${Keywords:-computer}
FIFO=askpi.fifo

pocketsphinx_continuous 2>/dev/null | while read line
do
print $line
	case $line in

	[0-9]*)
		[[ ${line#*: } == @($KEYWORDS) ]] && print LISTEN SPHINX >$FIFO
		;;
	esac
done
