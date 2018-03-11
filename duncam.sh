#!/bin/ksh

PIC1=./tmp/cam1.jpg WAV1=./tmp/cam1.wav
PIC2=./tmp/cam2.jpg WAV2=./tmp/cam2.wav
rm -f $PIC1 $PIC2 $WAV1 $WAV2

curl -s 'http://duncam@duncam1.home/image/jpeg.cgi' >$PIC1
curl -s 'http://duncam@duncam2.home/image/jpeg.cgi' >$PIC2
timeout 5s curl -s 'http://duncam@duncam1.home/audio.cgi' >$WAV1 &
timeout 5s curl -s 'http://duncam@duncam2.home/audio.cgi' >$WAV2 &
wait

cat - <<EOF
<img src="$PIC1" height=200>
<audio controls><source src="$WAV1"></audio>
<img src="$PIC2" height=200>
<audio controls><source src="$WAV2"></audio>
EOF
