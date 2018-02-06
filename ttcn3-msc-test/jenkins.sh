#!/bin/sh

set -x

# non-jenkins execution: assume local user name
if [ "x$REPO_USER" = "x" ]; then
	REPO_USER=$USER
fi

# non-jenkins execution: put logs in /tmp
if [ "x$WORKSPACE" = "x" ]; then
	WORKSPACE=/tmp
fi

NET_NAME="msc-tester"

echo Creating network $NET_NAME
docker network create --internal --subnet 172.18.1.0/24 $NET_NAME

VOL_BASE_DIR=`mktemp -d`
mkdir $VOL_BASE_DIR/msc-tester
mkdir $VOL_BASE_DIR/msc-tester/unix
cp MSC_Tests.cfg $VOL_BASE_DIR/msc-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/msc
mkdir $VOL_BASE_DIR/msc/unix
cp osmo-msc.cfg $VOL_BASE_DIR/msc/

mkdir $VOL_BASE_DIR/unix

echo Starting container with STP 
docker run	--rm \
		--network $NET_NAME --ip 172.18.1.200 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		$REPO_USER/osmo-stp-master

echo Starting container with MSC 
docker run	--rm \
		--network $NET_NAME --ip 172.18.1.10 \
		-v $VOL_BASE_DIR/msc:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-msc -d \
		$REPO_USER/osmo-msc-master \
		/usr/local/bin/osmo-msc -M /data/unix/mncc

echo Starting container with MSC testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.1.103 \
		-v $VOL_BASE_DIR/msc-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-ttcn3-msc-test \
		$REPO_USER/ttcn3-msc-test

echo Stopping containers
docker container kill msc
docker container kill stp

echo Deleting network $NET_NAME
docker network rm $NET_NAME

rm -rf $WORKSPACE/logs
mkdir -p $WORKSPACE/logs
cp -a $VOL_BASE_DIR/* $WORKSPACE/logs/
#rm -rf $VOL_BASE_DIR
