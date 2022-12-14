#!/bin/sh

trap "kill 0" EXIT

SLEEP_BEFORE_RESPAWN=${SLEEP_BEFORE_RESPAWN:-0}

i=0
max_i=500
while [ $i -lt $max_i ]; do
	echo "$i: starting: $*"
	gdb -ex 'handle SIG32 pass nostop noprint' -ex 'run' -ex 'bt full' --arg $* &
	LAST_PID=$!
	wait $LAST_PID
	echo "$i: stopped pid $LAST_PID with status $?"
	if [ $SLEEP_BEFORE_RESPAWN -gt 0 ]; then
		echo "sleeping $SLEEP_BEFORE_RESPAWN seconds..."
		sleep $SLEEP_BEFORE_RESPAWN
	fi
	i=$(expr $i + 1)
done
echo "exiting after $max_i runs"
