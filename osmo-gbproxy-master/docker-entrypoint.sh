#!/bin/bash
set -e
set -x

if [[ -n ${WAIT_FOR_NETDEV:-} ]]; then
	/usr/bin/pipework --wait -i ${WAIT_FOR_NETDEV}
fi

/usr/local/bin/osmo-gbproxy -c /data/osmo-gbproxy.cfg >/data/osmo-gbproxy.log 2>&1
