#!/bin/bash
set -eou pipefail

if [[ -n ${WAIT_FOR_NETDEV:-} ]]; then
	/usr/bin/pipework --wait -i ${WAIT_FOR_NETDEV}
fi

cd /data && /osmo-ttcn3-hacks/start-testsuite.sh /osmo-ttcn3-hacks/gbproxy/GBProxy_Tests; \
exit_code=$?

/osmo-ttcn3-hacks/log_merge.sh GBProxy_Tests --rm

exit $exit_code
