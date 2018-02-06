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

NET_NAME="m3ua-tester"

VOL_BASE_DIR=`mktemp -d`
mkdir $VOL_BASE_DIR/m3ua-tester
cp m3ua-param-testtool.scm all-sgp-tests.txt $VOL_BASE_DIR/m3ua-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

echo Creating network $NET_NAME
docker network create --internal --subnet 172.18.7.0/24 $NET_NAME

rm -rf $WORKSPACE/logs || /bin/true
mkdir -p $WORKSPACE/logs

# start container with STP in background
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network $NET_NAME --ip 172.18.7.200 \
		-v $VOL_BASE_DIR/stp:/data \
		--name stp \
		-d $REPO_USER/osmo-stp-master

# start docker container with tests
docker run	--rm \
		--network $NET_NAME --ip 172.18.7.2 \
		-v $VOL_BASE_DIR/m3ua-tester:/data \
		$REPO_USER/m3ua-test > $WORKSPACE/logs/junit-xml-m3ua.log

docker container stop -t 1 stp

echo Removing network $NET_NAME
docker network remove $NET_NAME

cp -a $VOL_BASE_DIR/* $WORKSPACE/logs/
