#!/bin/bash

[[ "" == "$MODULE_ADBPATH" ]] && \
    export readonly MODULE_ADBPATH="/data/local/tmp"

function module_import() {
    local m="$1"
    echo Loading "$m"
    source "$m"
}

function module_cwd() {
    echo $(readlink -f "${BASH_SOURCE[0]}")
}

function module_envsetup() {
    local target="$1"
    local cmdpush="adb push -s $target "
    local cmdshell="adb -s $target shell "

    [[ "" == "$target" ]] && { \
        target="$ps_adbtarget"
    }

    [[ "" == "$target" ]] && { \
        cmdpush="adb push "
        cmdshell="adb shell "
    }

    $cmdshell mkdir -p $MODULE_ADBPATH/perfsnippet/cpu
    $cmdshell mkdir -p $MODULE_ADBPATH/perfsnippet/gnuplot
    $cmdshell mkdir -p $MODULE_ADBPATH/perfsnippet/mem

    $cmdpush cpu/ $MODULE_ADBPATH/perfsnippet/cpu
    $cmdpush gnuplot/ $MODULE_ADBPATH/perfsnippet/gnuplot
    $cmdpush mem/ $MODULE_ADBPATH/perfsnippet/mem
    local i
    for i in *.sh; do
        $cmdpush $i $MODULE_ADBPATH/perfsnippet/
    done
}

function module_load() {
    export PATH_ROOT=`module_cwd`
    MODULE_MODULE_LOADED=true
}

function module_exit() {
    unset MODULE_MODULE_LOADED
}

if [[ "$MODULE_MODULE_LOADED" != 'true' ]]; then
    module_load
fi

module_envsetup

