#!/bin/bash
set -eou pipefail

SUBDIR=$1
SUITE=$2

if [[ -n ${WAIT_FOR_NETDEV:-} ]]; then
	/usr/bin/pipework --wait -i ${WAIT_FOR_NETDEV}
fi

cd /data && /osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/$SUBDIR/$SUITE; \
exit_code=$?

/osmo-ttcn3-hacks/log_merge.sh $SUITE --rm

exit $exit_code
