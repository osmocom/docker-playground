#!/bin/sh
set -e
set -x
/data/upfd-setup.sh
upfd_bin="$(command -v open5gs-upfd)"
# so_bindtodevice cfg requires CAP_NET_RAW:
setcap cap_net_raw+ep "$upfd_bin"
su - osmocom -c "$upfd_bin $*"
