#!/usr/bin/expect

spawn ssh -tt  kusime@rp4 -X


expect ".*fingerprint])?"
send  "yes\n"



expect ".*password:"
send "1q2w3e\n"

expect ".*~"
send "sudo "


interact

