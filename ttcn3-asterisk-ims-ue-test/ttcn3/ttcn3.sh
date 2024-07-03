#!/bin/bash
set +e
set -x

if [[ -z "${EXTRA_IPADDR}" ]]; then
  echo "env var EXTRA_IPADDR undefined!"
  exit 1
fi

ip addr add "${EXTRA_IPADDR}" dev eth0

ttcn3-docker-run asterisk Asterisk_Tests
