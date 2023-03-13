#!/bin/bash

function cpu_recorder_load() {
    echo cpu_recorder_load
}

function cpu_recorder_exit() {
    echo cpu_recorder_exit
}

function cpu_recorder_getstat() {
    cat /proc/stat
}

