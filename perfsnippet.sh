#!/bin/bash

[[ "" == "$PS_INTERVAL_DEFAULT" ]] && \
    export readonly PS_INTERVAL_DEFAULT=5

[[ "" == "$PS_DURATION_DEFAULT" ]] && \
    export readonly PS_DURATION_DEFAULT=300

[[ "" == "$PS_OUTPUTDIR_DEFAULT" ]] && \
    export readonly PS_OUTPUTDIR_DEFAULT=output

export ENABLE_DEBUG
export ENABLE_MEMINFO
export ENABLE_CPUINFO
export ENABLE_GFXINFO

export CONFIG_PS_INTERVAL
export CONFIG_PS_DURATION
export CONFIG_PS_ADBTARGET

export REQUEST_STARTDATETIME
export REQUEST_OUTPUTPATH
export REQUEST_OUTPUTFILE
export REQUEST_TERMINATE

export TESTSTEP_START
export TESTSTEP_DURATIONEND
export TESTSTEP_END
export TESTSTEP_ELPASED
export TESTSTEP_INDEX
export TESTSTEP_RECORD

export PRINTSTEP_FILENAME

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

    ENABLE_CPUINFO=true
    [[ "1" == "$ps_cpuinfo_disabled" ]] && { \
        ENABLE_CPUINFO=false
    }

    ENABLE_GFXINFO=true
    [[ "1" == "$ps_gfxinfo_disabled" ]] && { \
        ENABLE_GFXINFO=false
    }

    CONFIG_PS_INTERVAL=$PS_INTERVAL_DEFAULT
    [[ "0" -lt "$ps_interval" ]] && { \
        CONFIG_PS_INTERVAL=$ps_interval
    }

    CONFIG_PS_DURATION=$PS_DURATION_DEFAULT
    [[ "0" -lt "$ps_duration" ]] && { \
        CONFIG_PS_DURATION=$ps_duration
    }

    CONFIG_PS_ADBTARGET=
    [[ "" -ne "$ps_adbtarget" ]] && { \
        CONFIG_PS_ADBTARGET=$ps_adbtarget
    }
}

function perfsnippet_testplan_print() {
    echo "ENABLE_DEBUG\t$ENABLE_DEBUG"
    echo "ENABLE_MEMINFO\t$ENABLE_MEMINFO"
    echo "ENABLE_CPUINFO\t$ENABLE_CPUINFO"
    echo "ENABLE_GFXINFO\t$ENABLE_GFXINFO"

    echo "CONFIG_PS_INTERVAL\t$CONFIG_PS_INTERVAL"
    echo "CONFIG_PS_DURATION\t$CONFIG_PS_DURATION"
}

function perfsnippet_stop() {
    echo PerfSnippet STOPPING

    [[ "true" == "$ENABLE_MEMINFO" ]] && { \
        mem_entry_exit
    }

    [[ "true" == "$ENABLE_CPUINFO" ]] && { \
        cpu_entry_exit
    }

    # TODO
    # [[ "true" == "$ENABLE_GFXINFO" ]] && { \
        # gfx_entry_exit
    # }

    printer_finalize
}

function perfsnippet_testloop_start() {
    perfsnippet_printstep_prerun
    perfsnippet_teststep_prerun

    while
        [[ "true" == "$REQUEST_TERMINATE" ]] && break;

        let ++TESTSTEP_INDEX
        local now=$(timing_print_nowsecond)

        perfsnippet_teststep_run
        perfsnippet_printstep_run
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

    [[ "true" == "$ENABLE_MEMINFO" ]] && \
        mem_recorder_exit

    [[ "true" == "$ENABLE_CPUINFO" ]] && \
        cpu_recorder_exit

    # [[ "true" == "$ENABLE_GFXINFO" ]] && { \
        # module_import gfx/utils.sh
    # }

    plot_exit

    printer_exit
    utils_exit
    timing_exit
    module_exit
}

function perfsnippet_teststep_prerun() {
    TESTSTEP_INDEX=0
    TESTSTEP_ELPASED=0
    TESTSTEP_END=0
    TESTSTEP_START=$(timing_print_nowsecond)
    TESTSTEP_DURATIONEND=$(timing_print_timeoutsecond $CONFIG_PS_DURATION)

    local title="PerfSnippet record"
    local generatedby="PerfSnippet"
    local datetime="$REQUEST_STARTDATETIME"
    local description="Some performance data of Android device"

    # 1. Print gnuplot data file header
    local header="`plot_datafile_generateheader "$title" "$generatedby" "$datetime" "$description"`"
    printer_println "$header"
    printer_println "#"

    # 2. Print PerfSnippet parameters
    local testplan="`perfsnippet_testplan_print`"
    printer_println "#" $testplan
    printer_println "#"

    # 3. Print table column items
    local tableitem="`perfsnippet_generatetableitem`"
    printer_println "#" $tableitem
}

function perfsnippet_teststep_run() {
    perfsnippet_printdebug "PerfSnippet RUNNING"

    [[ "true" == "$ENABLE_MEMINFO" ]] && { \
        TESTSTEP_RECORD="$TESTSTEP_RECORD`mem_recorder_print`"
    }
    perfsnippet_printdebug "teststep_run MEM: $TESTSTEP_RECORD"

    [[ "true" == "$ENABLE_CPUINFO" ]] && { \
        cpu_recorder_statstep
        local cpustat="`cpu_recorder_get`"
        TESTSTEP_RECORD="$TESTSTEP_RECORD $cpustat"
    }
    perfsnippet_printdebug "teststep_run CPU: $TESTSTEP_RECORD"

    [[ "true" == "$ENABLE_GFXINFO" ]] && { \
        local get_fps="`source gfx/get_fps.sh`"
        local fps="`echo -e "$get_fps" | awk '{print $2}'`"
        TESTSTEP_RECORD="$TESTSTEP_RECORD $fps"
    }
    perfsnippet_printdebug "teststep_run GFX: $TESTSTEP_RECORD"
}

# 一小步测试步骤完成，执行间隔休眠使其满足间隔要求，根据interval-elpased计算本次需要休眠的时间
function perfsnippet_teststep_once() {
    TESTSTEP_RECORD=

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
    PRINTSTEP_FILENAME="perfsnippet_$REQUEST_STARTDATETIME.data"

    cpu_recorder_init

    REQUEST_OUTPUTPATH="$PS_OUTPUTDIR_DEFAULT/$REQUEST_STARTDATETIME"
    REQUEST_OUTPUTFILE="$REQUEST_OUTPUTPATH/$PRINTSTEP_FILENAME"
    printer_init "$REQUEST_OUTPUTFILE"

    printer_targetinfo
}

#TODO: 因为第一列存储X坐标，物理意义是表示测试过去的秒
# 这里传递进来$1是index，实际上秒数应该是index * CONFIG_PS_INTERVAL
function perfsnippet_printstep_run() {
    perfsnippet_printdebug perfsnippet_printstep_run: "$TESTSTEP_INDEX" "$TESTSTEP_RECORD"

    printer_println "$TESTSTEP_INDEX" "$TESTSTEP_RECORD"
}

function perfsnippet_printstep_postrun() {
    printer_finalize

    PRINTSTEP_FILENAME=
}

function perfsnippet_loadmodule() {
    source module.sh
    module_import utils.sh
    module_import timing.sh
    module_import printer.sh
    module_import gnuplot/gnuplot_wrapper.sh

    [[ "true" == "$ENABLE_MEMINFO" ]] && { \
        module_import mem/mem_entry.sh
    }

    [[ "true" == "$ENABLE_CPUINFO" ]] && { \
        module_import cpu/cpu_entry.sh
    }

    [[ "true" == "$ENABLE_GFXINFO" ]] && { \
        module_import gfx/utils.sh
    }
}

function perfsnippet() {
    perfsnippet_signal true
    perfsnippet_parse $*
    perfsnippet_loadmodule

    REQUEST_STARTDATETIME="$ps_startdatetime"
    [[ "" == "$REQUEST_STARTDATETIME" ]] && { \
        REQUEST_STARTDATETIME=`timing_print_nowdatetime`
    }

    mkdir -p $PS_OUTPUTDIR_DEFAULT/$REQUEST_STARTDATETIME

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
    perfsnippet_stop
}

function perfsnippet_printdebug() {
    [[ "true" != "$ENABLE_DEBUG" ]] && return

    >&2 \
    echo [debug]"\t$*"
}

function perfsnippet_generatetableitem() {
    # Index
    local items='Index'

    # Meminfo
    [[ "true" == "$ENABLE_MEMINFO" ]] && {\
        items="$items MemFree(MB)"
        items="$items MemAvai(MB)"
    }

    # Cpuinfo
    [[ "true" == "$ENABLE_CPUINFO" ]] && {\
        items="$items Usage(%)"
        items="$items USR(%)"
        items="$items SYS(%)"
        items="$items Other(%)"
        items="$items Idle(%)"
    }

    # Gfxinfo
    [[ "true" == "$ENABLE_GFXINFO" ]] && {\
        items="$items FPS"
    }

    echo -e "$items"
}

