#!/bin/sh -e
if [ $# -lt 2 ]; then
	echo
	echo "usage: ttcn3-docker-prepare OSMO_TTCN3_BRANCH PROJECT [PROJECT ...]"
	echo "arguments:"
	echo "  OSMO_TTCN3_BRANCH: as passed from docker"
	echo "  PROJECT: make target from osmo-ttcn3-hacks.git, e.g. 'msc'"
	echo
	exit 1
fi

set -x
OSMO_TTCN3_BRANCH=$1
PROJECT=$2

cd /osmo-ttcn3-hacks

git fetch
git checkout "$OSMO_TTCN3_BRANCH"

if git symbolic-ref -q HEAD; then
	git reset --hard origin/"$OSMO_TTCN3_BRANCH"
fi

git rev-parse --abbrev-ref HEAD
git rev-parse HEAD

make "$PROJECT"
