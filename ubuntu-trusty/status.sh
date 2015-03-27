#!/bin/bash

#
_battery_status_usage () {
	echo "usage: battery status [options]"
	echo -e "\t-h - print this help"
	echo -e "\t-H - show health"
	echo -e "\t-s - show electronical stats"
	echo -e "\t-i - show general battery information"

	return 1
}

#
_battery_status_health () {
	local full_by_design=`cat $_battery_path/charge_full_design`
	local full=`cat $_battery_path/charge_full`
	local unix_time=`date +%s`

	[ -e $_battery_share/health ] || {
		touch $_battery_share/health
	}

	echo "$unix_time $full_by_design $full" >> $_battery_share/health

	local result="$full of $full_by_design cells left ("
	result="$result"$(echo "scale = 2; ($full/$full_by_design) * 100" | bc)"%)"

	echo $result

	return 0
}

#
_battery_status_stats () {
	local f=1000000
	local a=$(echo "scale=2; "`cat $_battery_path/current_now`" / $f" | bc)
	local v=$(echo "scale=2; "`cat $_battery_path/voltage_now`" / $f" | bc)
	local w=`echo "scale=2; $a * $v" | bc`

	echo "I: $a A, U: $v V, P: $w W"

	return 0
}

#
_battery_status_info () {
	local tech=`cat $_battery_path/technology`
	local manu=`cat $_battery_path/manufacturer`
	# quoted cause serial numbers has tabs prepended
	local seri="`cat $_battery_path/serial_number`"

	echo "$tech from $manu (serial ${seri})"

	return 0
}

#
_battery_status_present () {
	# check if battery is present
	local presence=`cat $_battery_path/present`
	[ $presence -eq 1 ] && {
		echo "present"
	} || {
		echo "missing"
	}

	return 0
}

#
battery_status () {
	# create shared folder
	[ ! -e $_battery_share ] && {
		mkdir -p $_battery_share
	}

	local r

	[ $# -eq 0 ] && {
		_battery_status_usage
		r=22
	} || {
		while getopts hHsip option; do
			case "$option" in
				h) {
					_battery_status_usage
				} ;;

				H) {
					_battery_status_health
				} ;;

				s) {
					_battery_status_stats
				} ;;

				i) {
					_battery_status_info
				} ;;

				p) {
					_battery_status_present
				} ;;
			esac

			r=$?
		done
	}

	exit $r
}

battery_status $@
