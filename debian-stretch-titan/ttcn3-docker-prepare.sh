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
shift

cd /osmo-ttcn3-hacks

git fetch
git checkout "$OSMO_TTCN3_BRANCH"

if git symbolic-ref -q HEAD; then
	git reset --hard origin/"$OSMO_TTCN3_BRANCH"
fi

git rev-parse --abbrev-ref HEAD
git rev-parse HEAD

# Update deps if Makefile changed since last 'make deps' (e.g. because
# OSMO_TTCN3_BRANCH is different). The Dockerfile does the initial 'make deps'
# and downloads /tmp/deps-Makefile.
if ! diff -q /tmp/deps-Makefile deps/Makefile; then
	make deps
fi

# Link start/stop scripts to /
for i in ttcn3-*-start.sh ttcn3-*-stop.sh; do
	ln -sv "/osmo-ttcn3-hacks/$i" "/$i"
done

make $@
