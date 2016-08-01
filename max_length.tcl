#! /usr/bin/env expect

proc create_files {directory} {

    cd $directory

    set test_args {{mkdir "f0000000"}
        {mkdir "f00000000"}
        {ls}
    }

    foreach test $test_args {
        puts "Executing: $test"

        expect \
            "$server" { send "$test\r" }

        if { [catch {set result [exec ]} reason] } {

        puts "Failed execution: $reason"

        } else {

        puts $result

        }
    }

}