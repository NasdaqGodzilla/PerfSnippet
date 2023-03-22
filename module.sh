#!/bin/bash

export ADB_TARGET
export ADB_CMD_PUSH
export ADB_CMD_PULL
export ADB_CMD_SHELL

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
    local cmdpush="adb push -s $target --sync "
    local cmdpull="adb pull -s $target "
    local cmdshell="adb -s $target shell "

    [[ "" == "$target" ]] && { \
        target="$ps_adbtarget"
    }

    [[ "" == "$target" ]] && { \
        cmdpush="adb push --sync "
        cmdpull="adb pull "
        cmdshell="adb shell "
    }

    ADB_TARGET="$target"
    ADB_CMD_PUSH="$cmdpush"
    ADB_CMD_PULL="$cmdpull"
    ADB_CMD_SHELL="$cmdshell"

    $ADB_CMD_SHELL mkdir -p $MODULE_ADBPATH/perfsnippet/cpu
    $ADB_CMD_SHELL mkdir -p $MODULE_ADBPATH/perfsnippet/gnuplot
    $ADB_CMD_SHELL mkdir -p $MODULE_ADBPATH/perfsnippet/mem
    $ADB_CMD_SHELL mkdir -p $MODULE_ADBPATH/perfsnippet/gfx

    $ADB_CMD_PUSH cpu/ $MODULE_ADBPATH/perfsnippet/
    $ADB_CMD_PUSH gnuplot/ $MODULE_ADBPATH/perfsnippet/
    $ADB_CMD_PUSH mem/ $MODULE_ADBPATH/perfsnippet/
    $ADB_CMD_PUSH gfx/ $MODULE_ADBPATH/perfsnippet/
    local i
    for i in *.sh; do
        $ADB_CMD_PUSH $i $MODULE_ADBPATH/perfsnippet/
    done
}

function module_pulltestdata() {
    if [ ! -d "output" ]; then
        mkdir -p output
    fi

    local pathtestdata="$MODULE_ADBPATH/perfsnippet/output/$PRINTSTEP_FILENAME"
    $ADB_CMD_PULL $MODULE_ADBPATH/perfsnippet/output/
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

