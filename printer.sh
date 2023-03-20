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
        echo -e "$line" >> $PRINTER_PRINT_FILENAME
        return
    }

    echo -e "$line"
}

function printer_targetinfo_() {
    PRINTER_TARGETINFO=`echo -e \
        "Printer[$PRINTER_PRINT_TARGET/$PRINTER_PRINT_FILENAME]"`
}

function printer_targetinfo() {
    echo -e "$PRINTER_TARGETINFO"
}

function printer_test() {
    source module.sh
    module_import timing.sh

    local now="$REQUEST_STARTDATETIME"
    local filename="printer_test.$now.data"

    echo printer_test RUNNING

    echo Printing to $filename
    printer_init "$filename" ; { \
        printer_targetinfo

        printer_println hello
        printer_println nihao
        printer_println bonjour
        printer_println $now $filename
    }
    printer_finalize

    echo Printing to $PRINTER_TARGET_STDOUT
    printer_init && { \
        printer_targetinfo
        printer_println hello
        printer_println nihao
        printer_println bonjour
        printer_println 20230312
    }
    printer_finalize

    echo printer_test FINISED
}

function printer_finalize() {
    printer_sync

    unset PRINTER_INITED
    unset PRINTER_INFO
    unset PRINTER_PRINT_TARGET
    unset PRINTER_PRINT_FILENAME
}

function printer_sync() {
    [[ "true" != "$PRINTER_INITED" ]] && return
    [[ "$PRINTER_TARGET_FILE" != "$PRINTER_PRINT_TARGET" ]] && return
    [[ "" == "$PRINTER_PRINT_FILENAME" ]] && return

    fsync "$PRINTER_PRINT_FILENAME"
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

