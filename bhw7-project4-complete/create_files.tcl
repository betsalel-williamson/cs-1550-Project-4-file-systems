#! /usr/bin/env expect

proc create_files {directory} {

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

    if { [catch {set result [exec {*}[eval list {mkdir "foo1"}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result [exec {*}[eval list {ls}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    cd "foo1"

    set test_args {{echo "a" > 01.txt}
        {echo "a" > 02.txt}
        {echo "a" > 03.txt}
        {echo "a" > 04.txt}
        {echo "a" > 05.txt}
        {echo "a" > 06.txt}
        {echo "a" > 07.txt}
        {echo "a" > 08.txt}
        {echo "a" > 09.txt}
        {echo "a" > 10.txt}
        {echo "a" > 11.txt}
        {echo "a" > 12.txt}
        {echo "a" > 13.txt}
        {echo "a" > 14.txt}
        {echo "a" > 15.txt}
        {echo "a" > 16.txt}
        {echo "a" > 17.txt}
        {echo "a" > 18.txt}
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

    cd ".."

    if { [catch {set result [exec {*}[eval list {mkdir "foo"}]]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    cd "foo"

    foreach test $test_args {
        puts "Executing: $test"

        if { [catch {set result  [exec {*}[eval list $test]]} reason] } {

        puts "Failed execution: $reason"

        } else {

        puts $result

        }
    }

    cd {..}
}