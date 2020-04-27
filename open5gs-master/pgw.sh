#!/bin/sh
set -e
set -x
/root/setup.sh
su - osmocom -c "open5gs-pgwd $*"
