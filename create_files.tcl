#! /usr/bin/env expect

proc create_files {directory} {

    cd $directory

    if { [catch {set result [exec {*}[eval list {mkdir "f000"}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result [exec {*}[eval list {ls}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    cd "f000"

    if { [catch {set result [exec {*}[eval list {echo a > a.txt}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result [exec {*}[eval list {ls}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result [exec {*}[eval list {echo b > b.txt}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result [exec {*}[eval list {ls}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    cd ".."

    if { [catch {set result [exec {*}[eval list {mkdir "foo"}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result [exec {*}[eval list {ls}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    cd "foo"

    if { [catch {set result [exec {*}[eval list {echo a > a.txt}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result [exec {*}[eval list {ls}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result [exec {*}[eval list {echo b > b.txt}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result [exec {*}[eval list {ls}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }
}