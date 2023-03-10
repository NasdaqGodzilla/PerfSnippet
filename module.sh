#!/bin/bash

function module_import() {
    local m_ = "$1"
    echo Loading "$m_"
    source "$m_"
}

