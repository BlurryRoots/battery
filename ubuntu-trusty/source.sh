#!/bin/bash

# print usage
_battery_source_usage () {
	echo "usage: battery source [options]"
}

# checks from wich source you get your power right now
battery_source () {
	# laptop check, on_ac_power returns:
	#       0 (true)    System is on main power
	#       1 (false)   System is not on main power
	#       255 (false) Power status could not be determined
	# Desktop systems always return 255 it seems

	# check if neccessary tool is available
	which on_ac_power > /dev/null || {
		echo "Error: Could not find dependeny on_ac_power!"
		exit 1
	}

	# call power tool
	on_ac_power
	local powstat=$?

	# switch on result
	case $powstat in
		0) {
			echo "main"
			return 0
		};;

		1) {
			echo "accu"
			return 1
		};;

		*) {
			echo "Error: Could not determine power source!"
		};;
	esac

	exit 0
}

battery_source $@
