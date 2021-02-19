#!/usr/bin/expect

spawn ssh  -tt root@rp4


expect "The authenticity of.*"
send  "yes\n"


expect "*password:"     
send "yangyiming123\n"



interact

