#!/bin/sh

# non-jenkins execution: assume local user name
if [ "x$REPO_USER" = "x" ]; then
	REPO_USER=$USER
fi

# non-jenkins execution: put logs in /tmp
if [ "x$WORKSPACE" = "x" ]; then
	WORKSPACE=/tmp
fi

VOL_BASE_DIR=`mktemp -d`
mkdir $VOL_BASE_DIR/mgw-tester
cp MGCP_Test.cfg $VOL_BASE_DIR/mgw-tester/

mkdir $VOL_BASE_DIR/mgw
cp ../osmo-mgw-master/osmo-mgw.cfg $VOL_BASE_DIR/mgw/

# start container with mgw in background
docker run	--rm \
		--network sigtran --ip 172.18.0.180 \
		-v $VOL_BASE_DIR/mgw:/data \
		--name mgw -d \
		$REPO_USER/osmo-mgw-master

# start docker container with testsuite in foreground
docker run	--rm \
		--network sigtran --ip 172.18.0.181 \
		-v $VOL_BASE_DIR/mgw-tester:/data \
		$REPO_USER/mgw-test

# stop mgw after test has completed
docker container stop mgw

rm -rf $WORKSPACE/logs
mkdir -p $WORKSPACE/logs
cp -a $VOL_BASE_DIR/* $WORKSPACE/logs/
#rm -rf $VOL_BASE_DIR
