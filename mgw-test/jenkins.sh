#!/bin/sh

# non-jenkins execution: assume local user name
if [ "x$REPO_USER" = "x" ]; then
	REPO_USER=$USER
fi

# non-jenkins execution: put logs in /tmp
if [ "x$WORKSPACE" = "x" ]; then
	WORKSPACE=/tmp
fi

NET_NAME="mgw-tester"

VOL_BASE_DIR=`mktemp -d`
mkdir $VOL_BASE_DIR/mgw-tester
cp MGCP_Test.cfg $VOL_BASE_DIR/mgw-tester/

mkdir $VOL_BASE_DIR/mgw
cp osmo-mgw.cfg $VOL_BASE_DIR/mgw/

echo Creating network $NET_NAME
docker network create --internal --subnet 172.18.4.0/24 $NET_NAME

# start container with mgw in background
docker run	--rm \
		--network $NET_NAME --ip 172.18.4.180 \
		-v $VOL_BASE_DIR/mgw:/data \
		--name ${BUILD_TAG}-mgw -d \
		$REPO_USER/osmo-mgw-master

# start docker container with testsuite in foreground
docker run	--rm \
		--network $NET_NAME --ip 172.18.4.181 \
		-v $VOL_BASE_DIR/mgw-tester:/data \
		--name ${BUILD_TAG}-ttcn3-mgw-test \
		$REPO_USER/mgw-test

# stop mgw after test has completed
docker container stop mgw

echo Removing network $NET_NAME
docker network remove $NET_NAME

rm -rf $WORKSPACE/logs
mkdir -p $WORKSPACE/logs
cp -a $VOL_BASE_DIR/* $WORKSPACE/logs/
#rm -rf $VOL_BASE_DIR
