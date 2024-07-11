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

# Wait for Asterisk to be ready, which in turn may be waiting for dnsmasq to be ready...
for i in $(seq 100); do
  set -e
  netcat -z -v "${ASTERISK_IPADDR}" 5038 && break
  set +e
  echo "[$i] Asterisk AMI ${ASTERISK_IPADDR} (port 5038) not ready, waiting..."
  sleep 1
done

ttcn3-docker-run asterisk Asterisk_Tests
