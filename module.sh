#!/bin/bash

function module_import() {
    local m="$1"
    echo Loading "$m"
    source "$m"
}

function module_cwd() {
    echo $(readlink -f "${BASH_SOURCE[0]}")
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

