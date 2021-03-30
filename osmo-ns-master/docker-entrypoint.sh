#!/bin/bash
set -e
set -x

if [[ -n ${WAIT_FOR_NETDEV:-} ]]; then
	/usr/bin/pipework --wait -i ${WAIT_FOR_NETDEV}
fi

/usr/local/bin/osmo-ns-dummy -c /data/osmo-ns-dummy.cfg -p 4240 >/data/osmo-ns-dummy.log 2>&1
