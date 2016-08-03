#! /usr/bin/env expect

if { [catch {set result [exec rm .disk]} reason] } {

#puts "Failed exec rm .disk:\n$reason"
#exit -1

} else {

#puts $result

}

if { [catch {set result [exec dd bs=1K count=5K if=/dev/zero of=.disk]} reason] } {

#puts "Failed exec dd bs=1K count=5K if=/dev/zero of=.disk:\n$reason"
#exit -2

} else {

#puts $result

}