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

source [file join [file dirname [info script]] tests.tcl]

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

# general create directory tests
#create_directories{$directory}

# max length test
#max_length{$directory}

# create file test
create_files{$directory}
