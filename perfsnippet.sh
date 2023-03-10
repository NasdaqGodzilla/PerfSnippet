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

        local record="$(echo -e "`perfsnippet_recordstep_run`")"
        perfsnippet_teststep_once "$record"
        perfsnippet_testplan_review
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

# 执行完一次recorder
# 输出到目标
# 执行间隔休眠
function perfsnippet_teststep_once() {
    echo new record: $1
    sleep 1
}

# 确认测试计划是否完成，决定是否继续进行测试
function perfsnippet_testplan_review() {
    local testplan_reached=`perfsnippet_testplan_reached`
    [[ "true" == "$testplan_reached" ]] && { \
        perfsnippet_request_terminate
    }
}

# 是否达成测试目标
# TODO
function perfsnippet_testplan_reached() {
    echo false
}

function perfsnippet_teststep_postrun() {
    echo pass teststep postrun

    perfsnippet_signal

}

function perfsnippet_recordstep_prerun() {
    echo pass recordstep prerun

}

function perfsnippet_recordstep_run() {
    mem_recorder_print
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

