#!/bin/bash
export _battery_arch="ubuntu-trusty"

# prints usage
_battery_usage () {
	echo "usage: battery <cmd> [options] [args]"
	return 22
}

_batter_run () {
	[ $# -lt 1 ] && {
		_battery_usage
		return 1
	}

	local subfuncs="$BATTERY_LOCATION/$_battery_arch"

	[ ! -e $subfuncs/23-path ] && {
		echo "Missing configuration for device path (23-path)!"
		return 23
	}

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

	local cmd="$1"
	shift

	(export _battery_share=$sharepath; \
	 export _battery_path=$subpath; \
	 sh "$subfuncs/${cmd}.sh" $@)

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
				_batter_run $cmd $@
			} ;;

			"source") {
				_batter_run $cmd $@
			} ;;

			"status") {
				_batter_run $cmd $@
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
