#!/bin/bash

/usr/local/bin/tcpdump-start.sh nplab-sua-test

/usr/local/bin/runtest-junitxml.py -s 0.1 -t 10 -d /root /data/some-sua-sgp-tests.txt > /data/junit-xml-m3ua.log

/usr/local/bin/tcpdump-stop.sh nplab-sua-test
