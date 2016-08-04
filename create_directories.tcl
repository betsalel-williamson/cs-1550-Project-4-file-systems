#! /usr/bin/env expect

proc create_directories {directory} {

    cd $directory

    if { [catch {set result  [exec {*}[eval list {pwd}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result  [exec {*}[eval list {ls}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }
# test creating one past max number of subdirectories
    puts "\nExecuting: make max number of directories 'f01'\n"

    set test_args {{mkdir "f01"}
        {mkdir "f02"}
        {mkdir "f03"}
        {mkdir "f04"}
        {mkdir "f05"}
        {mkdir "f06"}
        {mkdir "f07"}
        {mkdir "f08"}
        {mkdir "f09"}
        {mkdir "f10"}
        {mkdir "f11"}
        {mkdir "f12"}
        {mkdir "f13"}
        {mkdir "f14"}
        {mkdir "f15"}
        {mkdir "f16"}
        {mkdir "f17"}
        {mkdir "f18"}
        {mkdir "f19"}
        {mkdir "f20"}
        {mkdir "f21"}
        {mkdir "f22"}
        {mkdir "f23"}
        {mkdir "f24"}
        {mkdir "f25"}
        {mkdir "f26"}
        {mkdir "f27"}
        {mkdir "f28"}
        {mkdir "f29"}
        {mkdir "f30"}
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

# test making duplicate entry
    puts "\nExecuting: make duplicate entry 'f01'\n"

    set test_args {{mkdir "f01"}
        {mkdir "f01"}
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

    cd f00

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