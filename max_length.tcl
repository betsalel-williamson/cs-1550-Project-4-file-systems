#! /usr/bin/env expect

proc max_length {directory server} {

    cd $directory

    set test_args {{mkdir {f0000000}}
        {mkdir {f00000000}}
        {ls}
    }

    foreach test $test_args {
        puts "Executing: $test"

        if { [catch {set result [exec {*}[eval list $test]]} reason] } {

        puts "Failed execution: $reason"

        } else {

        puts $result

        }
    }

    cd {..}

}