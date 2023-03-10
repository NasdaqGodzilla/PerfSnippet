#!/bin/bash

function timing_print_nowdatetime() {
    echo `date +"%Y%m%d_%H%M%S"`
}

function timing_print_nowsecond() {
    echo `date +%s`
}

# Elapsed seconds that after timestamp N
function timing_print_elapsed() {
    local N="$1"
    echo `date -d "$N second" +%S`
}

function timing_print_elpasedsecond() {
    local left="$1"
    local now=`timing_print_nowsecond`
    local elpased=`echo $now-$left | bc`
    echo -e $elpased
}

function timing_print_timeoutsecond() {
    local duration="$1"
    local left="$2"

    [[ "" == "$left" ]] && { \
        left=`timing_print_nowsecond`
    }

    local right=`echo $left+$duration | bc`
    echo -e $right
}

function timing_print_timeout() {
    local left="$1"
    local duration="$2"

    local now=`timing_print_nowsecond`
    local elpased=`echo $now-$left | bc`

    [[ "$elpased" -ge "$duration" ]] && { \
        echo true
        return
    }

    echo false
}

function timing_test() {
    local timeout=5.5
    local duration=30

    [[ "$1" -gt "0" ]] && { \
        timeout="$1"
    }
    [[ "$2" -gt "0" ]] && { \
        duration="$2"
    }

    local now=$(timing_print_nowsecond)

    echo left: $(timing_print_nowdatetime)/$now
    echo sleep $timeout; sleep $timeout
    echo Elapsed: `timing_print_elpasedsecond $now`
    echo right: $(timing_print_nowdatetime)/$(timing_print_nowsecond)

    echo $duration seconds later: `timing_print_timeoutsecond $duration`

    local elpased_sum=0
    local index=0
    while
        let ++index
        now=$(timing_print_nowsecond)

        echo "[$index] $now" sleep $timeout; sleep $timeout

        local elpased=`timing_print_elpasedsecond $now`
        let elpased_sum+=elpased

        echo "[$index] elpased: $elpased/`timing_print_nowsecond`"

        (( "$elpased_sum" < "$duration" ))
    do :; done

    echo $duration seconds sleep end at: `timing_print_nowsecond`
}

function timing_load() {
    MODULE_TIMING_LOADED=true
    echo timing_load
}

function timing_exit() {
    unset MODULE_TIMING_LOADED
}

if [[ "$MODULE_TIMING_LOADED" != 'true' ]]; then
        echo "Loading timing"
        timing_load
fi

