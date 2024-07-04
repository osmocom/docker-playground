#!/bin/bash
set +e
set -x

if [[ -z "${EXTRA_IPADDR}" ]]; then
  echo "env var EXTRA_IPADDR undefined!"
  exit 1
fi

ip addr add "${EXTRA_IPADDR}" dev eth0

# https://bugzilla.redhat.com/show_bug.cgi?id=782042
# IPv6 addresses may take an extra while to be available ('tentative' state):
while [ -n "$(ip -6 addr show tentative)" ]; do sleep 1; done

ttcn3-docker-run asterisk Asterisk_Tests
