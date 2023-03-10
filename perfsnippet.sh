#!/bin/bash

export ENABLE_MEMINFO

export REQUEST_TERMINATE=false

function perfsnippet_parse() {
    ENABLE_MEMINFO=true
    [[ "1" == "$ps_meminfo_disabled" ]] && { \
        echo "PerfSnippet meminfo disabled"
        ENABLE_MEMINFO=false
    }
}

function perfsnippet_testplan_print() {
    echo "ENABLE_MEMINFO\t$ENABLE_MEMINFO"
}

function perfsnippet_stop() {
    echo PerfSnippet STOPPING

    [[ "true" == "$ENABLE_MEMINFO" ]] && { \
        mem_entry_exit
    }
}

function perfsnippet_testloop_start() {
    perfsnippet_recordstep_prerun
    perfsnippet_teststep_prerun

    while true; do
        [[ "true" == "$REQUEST_TERMINATE" ]] && break;

        mem_recorder_print
        sleep 1
    done

    perfsnippet_teststep_postrun
    perfsnippet_recordstep_postrun
}

function perfsnippet_start() {
    perfsnippet_testplan_print
    echo PerfSnippet STARTING

    perfsnippet_testloop_start
    perfsnippet_finish
}

function perfsnippet_finish() {
    echo PerfSnippet FINISHED
}

function perfsnippet_teststep_prerun() {
    echo pass teststep prerun
}

# 执行recorder
function perfsnippet_teststep_run() {
    echo PerfSnippet RUNNING

}

function perfsnippet_teststep_postrun() {
    echo pass teststep postrun

    perfsnippet_signal

}

function perfsnippet_recordstep_prerun() {
    echo pass recordstep prerun

}

# 决定输出目标
function perfsnippet_recordstep_run() {
    echo pass recordstep run
}

function perfsnippet_recordstep_postrun() {
    echo pass recordstep postrun
}

function perfsnippet_loadmodule() {
    source module.sh
    module_import utils.sh

    [[ "true" == "$ENABLE_MEMINFO" ]] && { \
        module_import mem/mem_entry.sh
    }
}

function perfsnippet() {
    perfsnippet_signal true
    perfsnippet_parse $*
    perfsnippet_loadmodule
    perfsnippet_start
}

function perfsnippet_signal() {
    [[ "true" == "$1" ]] && { \
        trap  perfsnippet_request_terminate SIGHUP SIGINT SIGTERM EXIT
        return
    }

    trap - SIGHUP SIGINT SIGTERM EXIT
}

function perfsnippet_request_terminate() {
    REQUEST_TERMINATE=true
}

