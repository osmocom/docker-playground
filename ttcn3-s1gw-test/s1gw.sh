#!/bin/sh -ex

# the subnet prefix is to be modified by network_replace_subnet_in_configs()
ip addr add 172.18.10.100/24 dev eth0 || true  # primary address already set by docker_network_params()
ip addr add 172.18.10.200/24 dev eth0  # secondary address for eNB -> S1GW connections

# drop the root privileges and finally start osmo-s1gw
su build -c "/tmp/osmo-s1gw/_build/default/bin/osmo-s1gw"
