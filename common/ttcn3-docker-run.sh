#!/bin/bash
if [ $# -lt 2 ]; then
	echo
	echo "usage: ttcn3-docker-run SUBDIR SUITE"
	echo "arguments:"
	echo "  SUBDIR: directory in osmo-ttcn3-hacks, e.g. 'msc'"
	echo "  SUITE: name of the testsuite, e.g. 'MSC_Tests'"
	echo
	exit 1
fi

set -x
SUBDIR=$1
SUITE=$2

if [ -n "$WAIT_FOR_NETDEV" ]; then
	echo "Waiting for ${WAIT_FOR_NETDEV} to appear"
	pipework --wait -i "$WAIT_FOR_NETDEV"

	while true; do
		if [ ! -f /sys/class/net/${WAIT_FOR_NETDEV}/flags ]; then
			exit 23
		fi
		FLAGS=$(cat /sys/class/net/${WAIT_FOR_NETDEV}/flags)
		let FLAG_UP=$FLAGS\&1
		if [ "$FLAG_UP" = "1" ]; then
			break
		fi
		echo "Waiting for ${WAIT_FOR_NETDEV} to become operational"
		sleep 1
	done
fi

cd /data

/osmo-ttcn3-hacks/start-testsuite.sh "/osmo-ttcn3-hacks/$SUBDIR/$SUITE"
exit_code=$?

/osmo-ttcn3-hacks/log_merge.sh "$SUITE" --rm

exit $exit_code
