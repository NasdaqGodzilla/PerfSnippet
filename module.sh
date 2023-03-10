#!/bin/bash

function module_import() {
    local m="$1"
    echo Loading "$m"
    source "$m"
}

function module_cwd() {
    echo $(readlink -f "${BASH_SOURCE[0]}")
}

export PATH_ROOT=`module_cwd`

