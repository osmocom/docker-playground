#!/bin/sh

trap "kill 0" EXIT

i=0
max_i=500
while [ $i -lt $max_i ]; do
	echo "$i: starting: $*"
	$* &
	LAST_PID=$!
	wait $LAST_PID
	echo "$i: stopped pid $LAST_PID with status $?"
	i=$(expr $i + 1)
done
echo "exiting after $max_i runs"
