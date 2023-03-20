#!/bin/bash

function onexit() {
    module_pulltestdata
    exit
}

trap onexit SIGHUP SIGINT SIGTERM EXIT
source module.sh
module_envsetup
$ADB_CMD_SHELL "(cd $MODULE_ADBPATH/perfsnippet/; source perfsnippet.sh; perfsnippet)"
module_pulltestdata

