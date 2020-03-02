#!/bin/bash

# Add local IP addresses required by osmo-gsm-tester resources:
ip addr add 172.18.50.101/24 dev eth0

/usr/sbin/sshd -D -e
