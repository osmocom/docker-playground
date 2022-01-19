#!/bin/sh
set -e
set -x
/data/upfd-setup.sh
#du -lha / | grep freeDiameter
su - osmocom -c "open5gs-upfd $*"
