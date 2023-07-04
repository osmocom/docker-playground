#!/bin/sh
set -e
set -x
/data/mmed-setup.sh
mmed_bin="$(command -v open5gs-mmed)"
su - osmocom -c "$mmed_bin $*"
