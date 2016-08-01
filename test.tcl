#! /usr/bin/env expect

#/*
# * MIT License
# *
# * Copyright (c) 2016 Betsalel "Saul" Williamson
# *
# * contact: saul.williamson@pitt.edu
# *
# * Permission is hereby granted, free of charge, to any person obtaining a copy
# * of this software and associated documentation files (the "Software"), to deal
# * in the Software without restriction, including without limitation the rights
# * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# * copies of the Software, and to permit persons to whom the Software is
# * furnished to do so, subject to the following conditions:
# *
# * The above copyright notice and this permission notice shall be included in all
# * copies or substantial portions of the Software.
# *
# * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# * SOFTWARE.
# */

## note that the project must already exist on the remote server for this to run
set directory a
set server "thoth"

# could be used to pass clean argument to delete the build folder need to improve the handling of the switch case
set clean_build 0
if { $::argc > 0 } {
    set i 1
    foreach arg $::argv {
        puts "argument $i is $arg"
        switch $arg {
           -c {
              # then I should delete the config file and the build directory
              puts "Removing old disk.\n"
              set $clean_build 1
           }
           default {
              puts "Nothing found. Ingoring flag."
           }
        }
        incr i
    }
} else {
    puts "No command line argument passed."
}

# make directories test

#if {$clean_build} {

    if { [catch {set result [exec rm .disk]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

    if { [catch {set result [exec dd bs=1K count=5K if=/dev/zero of=.disk]} reason] } {

    puts "Failed execution: $reason"

    } else {

    puts $result

    }

#} else {
#    puts "\nUsing old disk.\n"
#}


cd $directory

# genearl create directory tests
#set test_args {{mkdir "f"}
#    {mkdir "f0"}
#    {mkdir "f00"}
#    {mkdir "f000"}
#    {mkdir "f0000"}
#    {mkdir "f00000"}
#    {mkdir "f000000"}
#    {mkdir "f0000000"}
#    {mkdir "f0000000"}
#    {mkdir "f00000000"}
#    {ls}
#}
#foreach test $test_args {
#    puts "Executing: $test"
#
#    expect \
#        "$server" { send "$test\r" }
#
#    if { [catch {set result [exec ]} reason] } {
#
#    puts "Failed execution: $reason"
#
#    } else {
#
#    puts $result
#
#    }
#}

# max length test
#set test_args {{mkdir "f0000000"}
#    {mkdir "f00000000"}
#    {ls}
#}
#
#foreach test $test_args {
#    puts "Executing: $test"
#
#    expect \
#        "$server" { send "$test\r" }
#
#    if { [catch {set result [exec ]} reason] } {
#
#    puts "Failed execution: $reason"
#
#    } else {
#
#    puts $result
#
#    }
#}

# create file test

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

#spawn sh

