#!/bin/bash

function mem_recorder_load() {
    echo mem_recorder_load
}

function mem_recorder_exit() {
    echo mem_recorder_exit
}

function mem_recorder_get_meminfo() {
    cat /proc/meminfo
}

# Get free mem from input meminfo, in kB
function mem_recorder_get_memfree() {
    local meminfo="$1"
    echo `echo -e "$meminfo" | awk '/MemFree/{print $2}'`
}

# Get available mem from input meminfo, in kB
function mem_recorder_get_memavai() {
    local meminfo="$1"
    echo `echo -e "$meminfo" | awk '/MemAvailable/{print $2}'`
}

function mem_recorder_test() {
    mem_recorder_get_memfree "echo `mem_recorder_get_meminfo`"
    mem_recorder_get_memavai "echo `mem_recorder_get_meminfo`"
}

mem_recorder_load

