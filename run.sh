#!/bin/bash

function onexit() {
    module_pulltestdata
    ondatapulled
    trap - SIGHUP SIGINT SIGTERM EXIT
    exit
}

function ondatapulled() {
    local datapath="$ps_gendatapath/$ps_gendatafile"
    echo Generatng for "$datapath"

    module_import gnuplot/gnuplot_renderer.sh
    plot_render_init "$datapath"
    plot_render_cmd
    plot_render_plot
}

trap onexit SIGHUP SIGINT SIGTERM EXIT
source module.sh
module_import timing.sh

ps_startdatetime=`timing_print_nowdatetime`
ps_gendatafile="perfsnippet_$ps_startdatetime.data"
ps_gendatapath="output/$ps_startdatetime"

module_envsetup
$ADB_CMD_SHELL "(cd $MODULE_ADBPATH/perfsnippet/; source perfsnippet.sh; ps_startdatetime=$ps_startdatetime perfsnippet)"
module_pulltestdata
ondatapulled
trap - SIGHUP SIGINT SIGTERM EXIT

