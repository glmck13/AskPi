#!/bin/ksh

PATH=$PWD:$PATH
ITAGOPTS=C3:25:A5:FA:58:FC
FIFO=askpi.fifo

typeset -i b

while true
do
	expect - <<-EOF  | while read x

	set timeout 100
	spawn gatttool -b ${ITAGOPTS} -I
	expect "> "

	while true {
		send "connect\r"
		expect {
			"Connection successful" { break }
			"Error:" { sleep 5; exit }
			"connect error:" { sleep 5; exit }
			timeout { sleep 5; exit }
		}
	}
	expect "> "

	send "char-read-hnd 0x0003\r"
	expect "> "

	send "char-read-uuid 0x2a19\r"
	expect "> "

	send "char-write-req 0x0036 0100\r"
	expect "Characteristic value was written successfully"
	expect "> "

	expect "WARNING"
	sleep 5
	EOF

	do

	if [[ $x == *Characteristic\ value/descriptor:* ]]; then
		Device="$(print ${x##*:} | xxd -r -p)"
		print "CONNECT $Device" >$FIFO

	elif [[ $x == *handle:\ 0x0030* ]]; then
		print ${x##*:} | read lo x
		b=16#${lo}
		print "BATTERY $Device:$b" >$FIFO

	elif [[ $x == *Notification\ handle\ =\ 0x0035\ value:\ 01* ]]; then
		print "LISTEN $Device" >$FIFO

	elif [[ $x == *Invalid\ file\ descriptor* ]]; then
		print "DISCONNECT $Device" >$FIFO
		x=${x%\)*} x=${x#*:}
		kill $x
	fi

	done
done
