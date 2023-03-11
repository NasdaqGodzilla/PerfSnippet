#!/bin/bash

[[ "" == "$PS_INTERVAL_DEFAULT" ]] && \
    export readonly PS_INTERVAL_DEFAULT=5

[[ "" == "$PS_DURATION_DEFAULT" ]] && \
    export readonly PS_DURATION_DEFAULT=300

export ENABLE_DEBUG
export ENABLE_MEMINFO

export CONFIG_PS_INTERVAL
export CONFIG_PS_DURATION

export REQUEST_TERMINATE

export TESTSTEP_START
export TESTSTEP_DURATIONEND
export TESTSTEP_END
export TESTSTEP_ELPASED
export TESTSTEP_INDEX

function perfsnippet_parse() {
    REQUEST_TERMINATE=false

    ENABLE_DEBUG=false
    [[ "1" == "$ps_debug" ]] && { \
        ENABLE_DEBUG=true
    }

    ENABLE_MEMINFO=true
    [[ "1" == "$ps_meminfo_disabled" ]] && { \
        ENABLE_MEMINFO=false
    }

    CONFIG_PS_INTERVAL=$PS_INTERVAL_DEFAULT
    [[ "0" -lt "$ps_interval" ]] && { \
        CONFIG_PS_INTERVAL=$ps_interval
    }

    CONFIG_PS_DURATION=$PS_DURATION_DEFAULT
    [[ "0" -lt "$ps_duration" ]] && { \
        CONFIG_PS_DURATION=$ps_duration
    }
}

function perfsnippet_testplan_print() {
    echo "ENABLE_DEBUG\t$ENABLE_DEBUG"
    echo "ENABLE_MEMINFO\t$ENABLE_MEMINFO"

    echo "CONFIG_PS_INTERVAL\t$CONFIG_PS_INTERVAL"
    echo "CONFIG_PS_DURATION\t$CONFIG_PS_DURATION"
}

function perfsnippet_stop() {
    echo PerfSnippet STOPPING

    [[ "true" == "$ENABLE_MEMINFO" ]] && { \
        mem_entry_exit
    }
}

function perfsnippet_testloop_start() {
    perfsnippet_printstep_prerun
    perfsnippet_teststep_prerun

    while
        [[ "true" == "$REQUEST_TERMINATE" ]] && break;

        let ++TESTSTEP_INDEX
        local now=$(timing_print_nowsecond)

        local record="$(echo -e "`perfsnippet_teststep_run`")"
        perfsnippet_printstep_run "$record"
        local elpased=`timing_print_elpasedsecond $now`
        let TESTSTEP_ELPASED+=elpased
        perfsnippet_teststep_once "$elpased"

        [[ "false" == $(perfsnippet_testplan_review) ]]
    do :; done

    perfsnippet_teststep_postrun
    perfsnippet_printstep_postrun
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
    TESTSTEP_INDEX=0
    TESTSTEP_ELPASED=0
    TESTSTEP_END=0
    TESTSTEP_START=$(timing_print_nowsecond)
    TESTSTEP_DURATIONEND=$(timing_print_timeoutsecond $CONFIG_PS_DURATION)
}

# 执行recorder
function perfsnippet_teststep_run() {
    perfsnippet_printdebug "PerfSnippet RUNNING"

    mem_recorder_print
}

# 一小步测试步骤完成，执行间隔休眠使其满足间隔要求，根据interval-elpased计算本次需要休眠的时间
function perfsnippet_teststep_once() {
    local elpased="$1"
    local would_sleep="$(echo $CONFIG_PS_INTERVAL-$elpased | bc)"
    [[ "0" -gt "$would_sleep" ]] && would_sleep=0

    [[ "true" == "$ENABLE_DEBUG" ]] && { \
        local progress="$(echo "$TESTSTEP_ELPASED" "$CONFIG_PS_DURATION" | \
                awk '{printf "%3.2f%%", $1 * 100 / $2}')"
        perfsnippet_printdebug "[$TESTSTEP_ELPASED/$CONFIG_PS_DURATION] $progress" \
            "ElpasedSum/elpased/Sleep: $TESTSTEP_ELPASED/$elpased/$would_sleep"
    }

    [[ "0" -ge "$would_sleep" ]] && return

    sleep $would_sleep
    let TESTSTEP_ELPASED+=would_sleep
}

# 确认测试计划是否完成，决定是否继续进行测试
function perfsnippet_testplan_review() {
    local testplan_reached=`perfsnippet_testplan_reached`
    [[ "true" == "$testplan_reached" ]] && { \
        perfsnippet_request_terminate
    }
    echo $testplan_reached
}

# 是否达成测试目标
function perfsnippet_testplan_reached() {
    [[ "$TESTSTEP_ELPASED" -lt "$CONFIG_PS_DURATION" ]] && { \
        echo false
        return
    }
    echo true
}

function perfsnippet_teststep_postrun() {
    TESTSTEP_END=$(timing_print_nowsecond)

    perfsnippet_signal
}

function perfsnippet_printstep_prerun() {
    echo pass printstep prerun

}

function perfsnippet_printstep_run() {
    perfsnippet_printdebug "New record: $1"
}

function perfsnippet_printstep_postrun() {
    echo pass printstep postrun
}

function perfsnippet_loadmodule() {
    source module.sh
    module_import utils.sh
    module_import timing.sh

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

function perfsnippet_printdebug() {
    [[ "true" != "$ENABLE_DEBUG" ]] && return

    >&2 \
    echo [debug]"\t$*"
}

