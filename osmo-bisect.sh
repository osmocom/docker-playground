#!/bin/sh

# Script to bisect an osmo-* project with the docker ttcn3 images
# You need the git checkout of the project you wand to test as well as a
# checkout of the docker-playground repository.

# Use like this from the osmo-* project repository where the regression
# occurs:
# $ git bisect start <bad-rev> <good-rev>
# $ git bisect run ~/scm/osmo/docker-playground/osmo-bisect.sh <component-to-test> <testcase>
# e.g.:
# $ git bisect run ~/scm/osmo/docker-playground/osmo-bisect.sh bsc BSC_Tests.TC_ho_in_fail_no_detect


DOCKER_PLAYGROUND=$(dirname "$0")
COMP_UPPER=$(echo "$1" | tr '[:lower:]' '[:upper:]')
COMP_LOWER=$(echo "$1" | tr '[:upper:]' '[:lower:]')
TESTCASE=$2

COMMIT=$(git log -1 --format=format:%H)

case $COMP_LOWER in
	"hnbgw"|\
	"bsc"|\
	"bts"|\
	"ggsn"|\
	"hlr"|\
	"mgw"|\
	"msc"|\
	"nitb"|\
	"pcu"|\
	"sgsn"|\
	"sip"|\
	"stp")
		BRANCH="OSMO_${COMP_UPPER}_BRANCH"
		SUITE="ttcn3-${COMP_LOWER}-test"
		;;
	*)
		echo "Unknown repo, please fix the script!"
		exit 125
		;;
esac

export "$BRANCH=$COMMIT"

cd "$DOCKER_PLAYGROUND/$SUITE" || exit 125

echo "Testing for $COMMIT"
./jenkins.sh | grep -- "====== $TESTCASE pass ======"
exit $?
