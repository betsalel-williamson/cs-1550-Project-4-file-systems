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

cmake_minimum_required(VERSION 2.6.4)

# read in configuration file
function(read_configuration_file file_name)
    file(STRINGS ${file_name} FILE_CONTENTS)
    string(REGEX MATCHALL "([^ {}]+ [^{}]+)" VariableList "${FILE_CONTENTS}")
    message(STATUS "Loading configuration file...\n")
    foreach (NameAndValue ${VariableList})
        #    message(STATUS "NameAndValue = ${NameAndValue}")
        #        # Find variable name
        #        string(LENGTH ${NameAndValue} len)
        #        string(FIND ${NameAndValue} " " num)
        #        message(STATUS "${NameAndValue} num=${num} len=${len}")
        string(REGEX MATCH "^[^ ]+" Name ${NameAndValue})
        # Find the value
        string(REGEX MATCH "([\"].+)$|([^ ]+)$" Value ${NameAndValue})
        # Set the variable
        set(${Name} "${Value}" PARENT_SCOPE)
        message(STATUS "{${Name} : ${Value}}")
    endforeach ()
endfunction(read_configuration_file)

read_configuration_file("config.txt")

if (IN_CYGWIN)
    #    message(status "Set cmake legacy setting")
    set(CMAKE_LEGACY_CYGWIN_WIN32 0)
    #else()
    #    message(status "Flag not set")
endif ()

if (CSV_OUTPUT)
    #    message(status "Set cmake legacy setting")
    add_definitions(-DCSV_OUTPUT)
    #else()
    #    message(status "Flag not set")
endif ()

#SET(CMAKE_C_FLAGS_DEBUG "-D_DEBUG")
#add_definitions(-DTRACE_FILE_LOCATION=${TRACE_FILE_LOCATION})

#add_definitions(-g)
#set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${${PROJECT_NAME}_SOURCE_DIR/}${BUILD_DIR})

# special debugger stuff for clion
#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -gdwarf-3")
#set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -gdwarf-3")

include_directories(".")

#add_subdirectory(fuse-2.7.0/include)
#add_subdirectory(test)

project(${PROJECT_NAME})

#add_definitions("-Wall -g -pthread")
#list(APPEND CMAKE_CXX_FLAGS "-pthread")

# Where Project's .h files can be found.
include_directories(fuse-2.7.0/include)

#include_directories(${${PROJECT_LIBS_NAME}_SOURCE_DIR}/include
#        ${${PROJECT_LIBS_NAME}_SOURCE_DIR})


find_package (Threads)

add_executable(${PROJECT_NAME} cs1550.c)

#target_link_libraries(${PROJECT_NAME} ${PROJECT_LIBS_NAME} ${CMAKE_THREAD_LIBS_INIT})
