#!/bin/sh
set -e
set -x
/data/upfd-setup.sh
tcpdump -i any -vvv -w /data/upfd.pcap &
upfd_bin="$(command -v open5gs-upfd)"
# so_bindtodevice cfg requires CAP_NET_RAW:
setcap cap_net_raw+ep "$upfd_bin"
su - osmocom -c "$upfd_bin $*"

# Wait for up to 2 seconds if we keep receiving traffinc from packet dumper,
# otherwise we might lose last packets from test.
i=0
prev_count=-1
count=$(stat --format="%s" "/data/upfd.pcap")
while [ $count -gt $prev_count ] && [ $i -lt 2 ]
do
	echo "Waiting for packet dumper to finish... $i (prev_count=$prev_count, count=$count)"
	sleep 1
	prev_count=$count
	count=$(stat --format="%s" "/data/upfd.pcap")
	i=$((i+1))
done
