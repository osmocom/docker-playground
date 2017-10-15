#!/bin/bash
docker network create --internal --subnet 172.18.0.0/16 sigtran
docker network create --internal --subnet 172.20.0.0/24 --ipv6 --subnet fd10:5741:8e20::0/64 pdn
