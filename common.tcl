#! /usr/bin/env tclsh8.5

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

# source for cf_read and cf_write:
# http://stackoverflow.com/questions/8054739/need-a-tcl-library-to-read-write-configuration-files

proc cf_read fname {
  set fd [open $fname]
  chan config $fd -encoding utf-8
  set data [read $fd]
  close $fd
  set data
}

proc cf_write {fname args} {
  set fd [open $fname w]
  chan config $fd -encoding utf-8
  set data [list]
  foreach varName $args {
    upvar 1 $varName var
    lappend data [list $varName $var]
  }
  puts $fd $data
  close $fd
}

#proc clean_build {} {
#  exec rm -rf _build\ config.txt
#}

#proc clean_logs {} {
#  exec rm -rf config.log test.log _build\build.log
#}

# could be used to pass clean argument to delete the build folder need to improve the handling of the switch case
#if { $::argc > 0 } {
#    set i 1
#    foreach arg $::argv {
#        puts "argument $i is $arg"
#        switch $arg {
#           -c {
#              # then I should delete the config file and the build directory
#              puts "Cleaning up build files"
#           }
#           -l {
#              puts "Cleaning up logs"
#              clean_logs
#           }
#           default {
#              puts "Nothing found. Ingoring flag."
#           }
#        }
#        incr i
#    }
#} else {
#    puts "No command line argument passed."
#}

set cfile [file join [file dir [info script]] config.txt]

set chan [open config.log a]
set timestamp [clock format [clock seconds]]
puts $chan "$timestamp\n"

if {[file exists config.txt]} {
  # this is a directory
  puts $chan "Found existing config file..."
} else {
  # not a directory set defaults
  puts $chan "New configuation file created..."

    set BUILD_DIR _build

    set PROJECT_NAME directoryProject

    set PROJECT_LIBS_NAME ProjectLibs

    set TEST_SUITE_NAME TestSuite

    set BUILD_SCRIPT_FILE ./build.tcl

    set TEST_SCRIPT_FILE ./test.tcl

    set TEST_EXE $BUILD_DIR/test/mainTests/$TEST_SUITE_NAME

    set MAIN_EXE $BUILD_DIR/$PROJECT_NAME

    set IN_CYGWIN 0

    set CMAKE_BUILD_TYPE Debug

    set CMAKE_MACOSX_RPATH 1

    set TRACE_FILE_LOCATION 1

# TODO this could be made into one list, but the issue was that these variables need to be set in addition to being written to the configuration file
  cf_write $cfile BUILD_DIR PROJECT_NAME PROJECT_LIBS_NAME TEST_SUITE_NAME BUILD_SCRIPT_FILE TEST_SCRIPT_FILE TEST_EXE MAIN_EXE IN_CYGWIN CMAKE_BUILD_TYPE CMAKE_MACOSX_RPATH
}

puts $chan "Reading in configuation file..."
foreach entry [cf_read $cfile] {
  lassign $entry name value
  set $name $value
    #  set
  puts $chan "$name: $value"
}
puts $chan "\n"

close $chan
