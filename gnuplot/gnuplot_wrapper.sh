#!/bin/bash

[[ "" == "$PLOT_DATAFILE_HEADERDEFAULT" ]] && \
    export readonly PLOT_DATAFILE_HEADERDEFAULT='gnuplot/gnuplot_data_header.h'

function plot_datafile_generateheader() {
    local line=

    while read -r line; do
        printf "$line\n" "$1"
        shift 1
    done < $PLOT_DATAFILE_HEADERDEFAULT
}

function plot_test() {
    echo plot_test RUNNING

    plot_datafile_generateheader $*

    echo plot_test FINISHED
}

function plot_load() {
    MODULE_PLOT_LOADED=true
    echo plot_load
}

function plot_exit() {
    unset MODULE_PLOT_LOADED
}

if [[ "$MODULE_PLOT_LOADED" != 'true' ]]; then
        echo "Loading plot"
        plot_load
fi

