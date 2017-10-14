#!/bin/ksh

PATH=$PWD:$PATH

FIFO=askpi.fifo

irw | while read key
do
	if [[ $key == *\ 00\ * ]]; then
		print LISTEN IR >$FIFO
	fi
done
