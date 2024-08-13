#!/bin/bash
set +e
set -x

EPDG_TUN="gtp0"
UE_IFACE="ue"
UE_SUBNET="192.168.0.0/16"
UE_ADDR="192.168.0.2/16"

ip link add $UE_IFACE type dummy
ip addr add $UE_ADDR dev $UE_IFACE
ip link set $UE_IFACE up
ip rule add from $UE_SUBNET table 45
if [ "$IMAGE_SUFFIX" = "latest" ]; then
	ERL_FLAGS='-config /data/osmo-epdg.config' /usr/bin/osmo-epdg &
else
	ERL_FLAGS='-config /data/osmo-epdg.config' /tmp/osmo-epdg/_build/default/bin/osmo-epdg &
fi
MYPID=$!

# We cannot set a route for the interface until it is created by osmo-epdg...
echo "Waiting for interface ${EPDG_TUN}..."
/data/pipework --wait -i ${EPDG_TUN}
echo "Adding src ${UE_SUBNET} default route to ${EPDG_TUN}"
ip route add default dev $EPDG_TUN table 45

wait $MYPID
