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

NET_NAME="sua-tester"

VOL_BASE_DIR=`mktemp -d`
mkdir $VOL_BASE_DIR/sua-tester
cp sua-param-testtool-sgp.scm some-sua-sgp-tests.txt $VOL_BASE_DIR/sua-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

echo Creating network $NET_NAME
docker network create --internal --subnet 172.18.6.0/24 $NET_NAME

rm -rf $WORKSPACE/logs || /bin/true
mkdir -p $WORKSPACE/logs

# start container with STP in background
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network $NET_NAME --ip 172.18.6.200 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp \
		-d $REPO_USER/osmo-stp-master

# start docker container with tests
docker run	--rm \
		--network $NET_NAME --ip 172.18.6.3 \
		-v $VOL_BASE_DIR/sua-tester:/data \
		--name ${BUILD_TAG}-sua-test \
		$REPO_USER/sua-test > $WORKSPACE/logs/junit-xml-sua.log

docker container stop -t 1 stp

echo Removing network $NET_NAME
docker network remove $NET_NAME

cp -a $VOL_BASE_DIR/* $WORKSPACE/logs/
