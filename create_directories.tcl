#! /usr/bin/env expect

proc create_directories {directory} {

    cd $directory

    set test_args {{mkdir "f"}
        {mkdir "f0"}
        {mkdir "f00"}
        {mkdir "f000"}
        {mkdir "f0000"}
        {mkdir "f00000"}
        {mkdir "f000000"}
        {mkdir "f0000000"}
        {mkdir "f0000000"}
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