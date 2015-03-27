#!/bin/bash

# print usage
_battery_source_usage () {
	echo "usage: battery source [options]"
}

# checks from wich source you get your power right now
battery_source () {
	local power_mode=`cat $_battery_path/status`

	echo $power_mode

	exit 0
}

battery_source $@
