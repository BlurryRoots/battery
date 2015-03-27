#!/bin/bash

#
_battery_left_usage () {
	echo "usage: battery left [options]"
}

# calculate something ($2) with a certain precision ($1)
batter_left_calc () {
	local precision="scale = $1"
	local formular="$2"
	local bc_arg="$precision; $formular"

	echo $(echo "$bc_arg" | bc -l)
}

#
batter_left_percent () {
	local charge_now=`cat $_battery_path/charge_now`
	local charge_full=`cat $_battery_path/charge_full`

	local formular="($charge_now / $charge_full) * 100"
	echo $(batter_left_calc 2 "$formular")%
}

#
batter_left_time () {
	local charge_full=`cat $_battery_path/charge_full`
	local current_now=`cat $_battery_path/current_now`

	local formular="($charge_full / $current_now)"
	local hours_left=$(batter_left_calc 2 "$formular")
	local hours_only=$(batter_left_calc 0 "$hours_left / 1")
	local minutes_only_point=$(batter_left_calc 2 "($hours_left - $hours_only) * 60")
	local minutes_only=$(batter_left_calc 0 "$minutes_only_point / 1")

	echo "$hours_only h, $minutes_only m"
}

#
battery_left () {
	local r

	[ $# -eq 0 ] && {
		echo "$(batter_left_time) ($(batter_left_percent))"
	} || {
		while getopts hpt option; do
			case "$option" in
				h) {
					_battery_left_usage
				} ;;

				p) {
					batter_left_percent
				} ;;

				t) {
					batter_left_time
				} ;;
			esac

			r=$?
		done
	}

	exit $r
}

battery_left $@
