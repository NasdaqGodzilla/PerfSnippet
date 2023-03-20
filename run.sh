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
    # plot_render_init "$datapath"
    plot_render_init "$ps_gendatafile"
    cd "$ps_gendatapath"
    plot_render_plot
    cd -
}

ENABLE_MEMINFO=true
[[ "1" == "$ps_meminfo_disabled" ]] && { \
    ENABLE_MEMINFO=false
}

ENABLE_CPUINFO=true
[[ "1" == "$ps_cpuinfo_disabled" ]] && { \
    ENABLE_CPUINFO=false
}

trap onexit SIGHUP SIGINT SIGTERM EXIT
source module.sh
module_import timing.sh

ps_startdatetime=`timing_print_nowdatetime`
ps_gendatafile="perfsnippet_$ps_startdatetime.data"
ps_gendatapath="output/$ps_startdatetime"

module_envsetup
$ADB_CMD_SHELL "(cd $MODULE_ADBPATH/perfsnippet/; source perfsnippet.sh; ps_meminfo_disabled=$ps_meminfo_disabled ps_cpuinfo_disabled=$ps_cpuinfo_disabled ps_startdatetime=$ps_startdatetime ps_debug=$ps_debug ps_interval=$ps_interval ps_duration=$ps_duration ps_adbtarget=$ps_adbtarget perfsnippet)"
module_pulltestdata
ondatapulled
trap - SIGHUP SIGINT SIGTERM EXIT

