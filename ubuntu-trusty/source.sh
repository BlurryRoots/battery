#!/bin/bash

# print usage
_battery_source_usage () {
	echo "usage: battery source [options]"
	echo "\t-h - print this help"

	return 22
}

# checks from wich source you get your power right now
battery_source () {
	local power_mode=`cat $_battery_path/status`

	local r

	[ $# -eq 0 ] && {
		echo "Power mode: $power_mode"
	} || {
		while getopts hpt option; do
			case "$option" in
				h) {
					_battery_source_usage
				} ;;

				*) {
					echo "battery source: unknown option!"
					_battery_source_usage
				} ;;
			esac

			r=$?
		done
	}

	exit $r

	exit 0
}

battery_source $@
