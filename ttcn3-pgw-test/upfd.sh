#!/bin/sh
set -e
set -x
/data/upfd-setup.sh
su - osmocom -c "open5gs-upfd $*"
