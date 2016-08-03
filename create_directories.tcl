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

        if { [catch {set result  [exec {*}[eval list $test]]} reason] } {

        puts "Failed execution: $reason"

        } else {

        puts $result

        }
    }

# should return error
    puts "\nExecuting: make subdir 'f0' in dir 'f00'\n"

    cd "f00"

    if { [catch {set result [exec {*}[eval list {mkdir "f0"}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result [exec {*}[eval list {ls}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    cd {..}

    cd {..}

}