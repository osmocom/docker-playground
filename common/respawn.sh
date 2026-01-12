#!/bin/sh

trap "kill 0" EXIT

SLEEP_BEFORE_RESPAWN=${SLEEP_BEFORE_RESPAWN:-0}

i=0
max_i=500
while [ $i -lt $max_i ]; do
	echo "[$(date)] respawn: $i: starting: $*"
	$* &
	LAST_PID=$!
	sleep 5
	echo "lsof output:"
	lsof +f g -p $LAST_PID
	echo "maps output:"
	cat /proc/$LAST_PID/maps
	wait $LAST_PID
	echo "[$(date)] respawn: $i: stopped pid $LAST_PID with status $?"
	if [ $SLEEP_BEFORE_RESPAWN -gt 0 ]; then
		echo "[$(date)] respawn: sleeping $SLEEP_BEFORE_RESPAWN seconds..."
		sleep $SLEEP_BEFORE_RESPAWN
	fi
	i=$(expr $i + 1)
done
echo "[$(date)] respawn: exiting after $max_i runs"
