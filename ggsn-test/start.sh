#!/bin/sh
docker volume rm ggsn-test-vol
docker run --rm --network sigtran --ip 172.18.0.202 -v ggsn-test-vol:/data -it ggsn-test
