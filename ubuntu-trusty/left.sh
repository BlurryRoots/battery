#!/bin/bash

#
_battery_left_usage () {
	echo "usage: battery left [options]"
	echo "\t-h - print this help"
	echo "\t-p - percentage"
	echo "\t-t - in hours and minutes"

	return 22
}

# calculate something ($2) with a certain precision ($1)
_battery_left_calc () {
	local precision="scale = $1"
	local formular="$2"
	local bc_arg="$precision; $formular"

	echo $(echo "$bc_arg" | bc -l)
}

#
_battery_left_percent () {
	local charge_now=`cat $_battery_path/charge_now`
	local charge_full=`cat $_battery_path/charge_full`

	local formular="($charge_now / $charge_full) * 100"
	echo $(_battery_left_calc 2 "$formular")%

	return 0
}

#
_battery_left_time () {
	local mode_name=`cat $_battery_path/status`
	local charge_now=`cat $_battery_path/charge_now`
	local resulting_state="discharged"
	if [ "Charging" = "$mode_name" ]; then
		local charge_full=`cat $_battery_path/charge_full`
		charge_now=$(_battery_left_calc 0 "$charge_full - $charge_now")
		resulting_state="charged"
	fi

	local current_now=`cat $_battery_path/current_now`

	local formular="($charge_now / $current_now)"
	local hours_left=$(_battery_left_calc 2 "$formular")
	local hours_only=$(_battery_left_calc 0 "$hours_left / 1")
	local minutes_only_point=$(_battery_left_calc 2 "($hours_left - $hours_only) * 60")
	local minutes_only=$(_battery_left_calc 0 "$minutes_only_point / 1")

	echo "$hours_only h, $minutes_only m until $resulting_state"

	return 0
}

#
battery_left () {
	local r

	[ $# -eq 0 ] && {
		echo "$(_battery_left_time) ($(_battery_left_percent))"
	} || {
		while getopts hpt option; do
			case "$option" in
				h) {
					_battery_left_usage
				} ;;

				p) {
					_battery_left_percent
				} ;;

				t) {
					_battery_left_time
				} ;;

				*) {
					echo "battery left: unknown option!"
					_battery_left_usage
				} ;;
			esac

			r=$?
		done
	}

	exit $r
}

battery_left $@
