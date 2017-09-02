#!/bin/ksh

PATH=$PWD:$PATH

#REMOTE="sshpass -p <password> ssh <user>@<host> <path>/"
FIFO=askpi.fifo

${REMOTE}ircat --config=~/.config/lircrc askpi >$FIFO
