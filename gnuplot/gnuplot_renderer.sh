#!/bin/bash

[[ "" == "$PLOT_SCRIPTFILE_INIT" ]] && \
    export readonly PLOT_SCRIPTFILE_INIT='gnuplot/gnuplot.init.cmd'

[[ "" == "$PLOT_SCRIPTFILE_CPU" ]] && \
    export readonly PLOT_SCRIPTFILE_CPU='gnuplot/gnuplot.cpu.cmd'

[[ "" == "$PLOT_SCRIPTFILE_MEM" ]] && \
    export readonly PLOT_SCRIPTFILE_MEM='gnuplot/gnuplot.mem.cmd'

[[ "" == "$PLOT_SCRIPTFILE_CPUMEM" ]] && \
    export readonly PLOT_SCRIPTFILE_CPUMEM='gnuplot/gnuplot.cpumem.cmd'

[[ "" == "$PLOT_SCRIPTFILE_GFX" ]] && \
    export readonly PLOT_SCRIPTFILE_GFX='gnuplot/gnuplot.gfx.cmd'

export PLOT_RENDER_COMMAND

function plot_render_init() {
    plot_render_finalize

    local datafile="$1"
    PLOT_RENDER_COMMAND="DATAFILE=\"$datafile\""

    plot_render_init_outputsize
    plot_render_init_each
}

function plot_render_plot() {
    gnuplot -e "`plot_render_cmd`"
}

function plot_render_init_outputsize() {
    local layout=0
    local height=0

    [[ "true" == "$ENABLE_MEMINFO" ]] && { \
        let layout+=2
    }

    [[ "true" == "$ENABLE_CPUINFO" ]] && { \
        let ++layout
    }

    [[ "true" == "$ENABLE_MEMINFO" ]] && [[ "true" == "$ENABLE_CPUINFO" ]] && { \
        let layout+=2
    }

    [[ "true" == "$ENABLE_GFXINFO" ]] && { \
        let ++layout
    }

    let height=layout*400

    # local cmd="set term svg size 1000, $height #\"Helvetica\" 16"
    local cmd="set term svg size 1000, $height"
    cmd="$cmd; set output sprintf(\"output_%s@%s.svg\", DATAFILE, strftime('%Y%m%d_%H%M%S', time(0)))"
    cmd="$cmd; set multiplot layout $layout,1"
    plot_render_cmdconcat "$cmd"
}

function plot_render_init_each() {
    plot_render_cmdfrom "$PLOT_SCRIPTFILE_INIT"

    [[ "true" == "$ENABLE_MEMINFO" ]] && [[ "true" == "$ENABLE_CPUINFO" ]] && { \
        plot_render_cmdfrom "$PLOT_SCRIPTFILE_CPUMEM"
    }

    [[ "true" == "$ENABLE_MEMINFO" ]] && { \
        plot_render_cmdfrom "$PLOT_SCRIPTFILE_MEM"
    }

    [[ "true" == "$ENABLE_CPUINFO" ]] && { \
        plot_render_cmdfrom "$PLOT_SCRIPTFILE_CPU"
    }

    [[ "true" == "$ENABLE_GFXINFO" ]] && { \
        plot_render_cmdfrom "$PLOT_SCRIPTFILE_GFX"
    }
}

function plot_render_cmdfrom() {
    local scriptfile="$1"

    while read -r line; do
        plot_render_cmdconcat "$line"
    done < $scriptfile
}

function plot_render_cmdconcat() {
    PLOT_RENDER_COMMAND="$PLOT_RENDER_COMMAND; $*"
}

function plot_render_cmd() {
    echo -e "$PLOT_RENDER_COMMAND"
}

function plot_render_test() {
    echo plot_render_test RUNNING

    ENABLE_CPUINFO=true
    ENABLE_MEMINFO=true

    plot_render_init "perfsnippet_20230314_201937.data"
    plot_render_cmd
    plot_render_plot

    echo plot_render_test FINISHED
}

function plot_render_finalize() {
    PLOT_RENDER_COMMAND=
}

function plot_render_load() {
    MODULE_PLOTRENDER_LOADED=true
    echo plot_render_load
}

function plot_render_exit() {
    unset MODULE_PLOTRENDER_LOADED
}

if [[ "$MODULE_PLOTRENDER_LOADED" != 'true' ]]; then
        echo "Loading plotrender"
        plot_render_load
fi

