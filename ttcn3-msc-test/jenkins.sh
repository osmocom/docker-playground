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
		--network sigtran --ip 172.18.0.200 \
		-v $VOL_BASE_DIR/stp:/data \
		--name stp -d \
		$REPO_USER/osmo-stp-master

echo Starting container with MSC 
docker run	--rm \
		--network sigtran --ip 172.18.0.10 \
		-v $VOL_BASE_DIR/msc:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name msc -d \
		$REPO_USER/osmo-msc-master \
		/usr/local/bin/osmo-msc -M /data/unix/mncc

echo Starting container with MSC testsuite
docker run	--rm \
		--network sigtran --ip 172.18.0.103 \
		-v $VOL_BASE_DIR/msc-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ttcn3-msc-test \
		$REPO_USER/ttcn3-msc-test

echo Stopping containers
docker container kill msc
docker container kill stp

rm -rf $WORKSPACE/logs
mkdir -p $WORKSPACE/logs
cp -a $VOL_BASE_DIR/* $WORKSPACE/logs/
#rm -rf $VOL_BASE_DIR
