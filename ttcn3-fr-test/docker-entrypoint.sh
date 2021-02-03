#!/bin/bash
set -eou pipefail

SUBDIR=$1
SUITE=$2

if [[ -n ${WAIT_FOR_NETDEV:-} ]]; then
	echo Waiting for ${WAIT_FOR_NETDEV} to appear
	# this unfortunately only waits until the device exists
	/usr/bin/pipework --wait -i ${WAIT_FOR_NETDEV}
	# here we have to wait until it is up
	while true; do
		if [ ! -f /sys/class/net/${WAIT_FOR_NETDEV}/operstate ]; then
			exit 23
		fi
		OPSTATE=`cat /sys/class/net/${WAIT_FOR_NETDEV}/operstate`
		if [ "$OPSTATE" == "up" ]; then
			break
		fi
		echo Waiting for ${WAIT_FOR_NETDEV} to become operational
		sleep 1
	done
fi

cd /data && /osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/$SUBDIR/$SUITE; \
exit_code=$?

/osmo-ttcn3-hacks/log_merge.sh $SUITE --rm

exit $exit_code
