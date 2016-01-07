#!/bin/bash
export _battery_arch="ubuntu-trusty"

# prints usage
_battery_usage () {
	echo "usage: battery <command> [options] [args]\n"
	echo "type 'battery help <command>' to get help for a specific command\n"
	echo "available commands:\n"
	echo "\tleft"
	echo "\tsource"
	echo "\tstatus"

	return 22
}

_battery_run () {
	# exit if no parameters are given
	[ $# -lt 1 ] && {
		_battery_usage
		return 1
	}

	# check for proper configuration
	local subfuncs="$BATTERY_LOCATION/$_battery_arch"
	# device path?
	[ ! -e $subfuncs/23-path ] && {
		echo "Missing configuration for device path (23-path)!"
		return 23
	}
	# shared folder?
	[ ! -e $subfuncs/24-share ] && {
		echo "Missing configuration for shared folder (24-share)!"
		return 24
	}

	# check for dependency
	which envsubst > /dev/null || {
		echo "Missing dependency: envsubst"
		return 1
	}

	# use the envsubst tool to resolve variables used in config file
	# dont use path ! (zsh uses this var globally, *facepalm*)
	local subpath=$(envsubst < $subfuncs/23-path)
	local sharepath=$(envsubst < $subfuncs/24-share)

	# store first command in queue to use it as the name of the file
	# containing the subprogram
	local cmd="$1"
	# and shift it of the queue
	shift

	# run the subfunction in a seperate context, with helper variables
	(export _battery_share=$sharepath; \
	 export _battery_path=$subpath; \
	 sh "$subfuncs/${cmd}.sh" $@)

	# return the last status code of the command
	return $?
}

# main function
battery_main () {
	local r

	if [ $# -eq 0 ]; then
		# if there is no parameter print usage
		_battery_usage
		r=1
	else
		# read command paramter
		local cmd="$1"
		shift

		# switch on command (man are fallthroughs ugly!)
		case $cmd in
			"left") {
				_battery_run $cmd $@
			} ;;

			"source") {
				_battery_run $cmd $@
			} ;;

			"status") {
				_battery_run $cmd $@
			} ;;

			*) {
				echo "battery: unknown command!"
				_battery_usage
			} ;;
		esac

		r=$?
	fi

	return $r
}

battery_main $@
