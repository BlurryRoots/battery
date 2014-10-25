#!/bin/bash

#
_battery_left_usage () {
	echo "usage: battery left [options]"
}

#
battery_left () {
	local batdir="$_battery_path/uevent"
	local rx="POWER_SUPPLY_CHARGE_NOW=([0-9]+)"

	local cfull
	local cnow

	#
	cnow=$(cat $batdir | {
		# -n not print all lines -r activate regex
		# s/(searching) /(matching) /p(print) 
		sed -nr "s/POWER_SUPPLY_CHARGE_NOW=([0-9]+)/\1/p"
	})

	#
	cfull=$(cat $batdir | {
		# -n not print all lines -r activate regex
		# s/(searching) /(matching) /p(print) 
		sed -nr "s/POWER_SUPPLY_CHARGE_FULL=([0-9]+)/\1/p"
	})

	echo $(echo "scale = 2; ($cnow/$cfull) * 100" | bc)%
}

battery_left $@
