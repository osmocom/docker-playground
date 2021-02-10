#!/bin/sh
if [ $# -lt 2 ]; then
	echo
	echo "usage: ttcn3-docker-run SUBDIR SUITE"
	echo "arguments:"
	echo "  SUBDIR: directory in osmo-ttcn3-hacks, e.g. 'msc'"
	echo "  SUITE: name of the testsuite, e.g. 'MSC_Tests'"
	echo
	exit 1
fi

set -x
SUBDIR=$1
SUITE=$2

cd /data

/osmo-ttcn3-hacks/start-testsuite.sh "/osmo-ttcn3-hacks/$SUBDIR/$SUITE"
exit_code=$?

/osmo-ttcn3-hacks/log_merge.sh "$SUITE" --rm

exit $exit_code
