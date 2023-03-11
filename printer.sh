#!/bin/bash

[[ "" == "$PRINTER_TARGET_STDOUT" ]] && \
    export readonly PRINTER_TARGET_STDOUT="stdout"

[[ "" == "$PRINTER_TARGET_FILE" ]] && \
    export readonly PRINTER_TARGET_FILE="file"

export PRINTER_PRINT_TARGET
export PRINTER_PRINT_FILENAME

export PRINTER_INITED
export PRINTER_INFO

function printer_init() {
    [[ "" != "$PRINTER_INITED" ]] && return

    local filename="$1"
    local target="$2"

    PRINTER_PRINT_TARGET="$PRINTER_TARGET_STDOUT"
    [[ "$PRINTER_TARGET_STDOUT" != "$target" ]] && \
        PRINTER_PRINT_TARGET="$PRINTER_TARGET_FILE"

    unset PRINTER_PRINT_FILENAME
    [[ "$PRINTER_TARGET_FILE" == "$PRINTER_PRINT_TARGET" ]] && { \
        PRINTER_PRINT_FILENAME="$filename"
    }
    [[ "" == "$PRINTER_PRINT_FILENAME" ]] && { \
        PRINTER_PRINT_TARGET="$PRINTER_TARGET_STDOUT"
    }

    [[ -f "$PRINTER_PRINT_FILENAME" ]] && { \
        echo "$PRINTER_PRINT_FILENAME exists!"
        unset PRINTER_PRINT_FILENAME
        PRINTER_PRINT_TARGET="$PRINTER_TARGET_STDOUT"
    }

    printer_targetinfo_

    PRINTER_INITED=true
}

function printer_println() {
    local line="$*"
    local target_cmd=

    [[ "$PRINTER_TARGET_FILE" == "$PRINTER_PRINT_TARGET" ]] && { \
        target_cmd=" >> $PRINTER_TARGET_FILE"
    }

    eval echo -e "$line" "$target_cmd"
}

function printer_targetinfo_() {
    PRINTER_TARGETINFO=`echo -e \
        "Printer[$PRINTER_PRINT_TARGET/$PRINTER_PRINT_FILENAME]"`
}

function printer_targetinfo() {
    echo -e "$PRINTER_TARGETINFO"
}

function printer_test() {
    echo printer_test
}

function printer_finalize() {
    printer_sync

    unset PRINTER_INITED
    unset PRINTER_INFO
    unset PRINTER_PRINT_TARGET
    unset PRINTER_PRINT_FILENAME
}

function printer_sync() {
    echo printer_sync

    [[ "true" != "$PRINTER_INITED" ]] && return
}

function printer_load() {
    MODULE_PRINTER_LOADED=true
    echo printer_load
}

function printer_exit() {
    unset MODULE_PRINTER_LOADED
}

if [[ "$MODULE_PRINTER_LOADED" != 'true' ]]; then
        echo "Loading printer"
        printer_load
fi

