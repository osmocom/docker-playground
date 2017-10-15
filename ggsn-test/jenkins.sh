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
mkdir $VOL_BASE_DIR/ggsn-tester
cp GGSN_Tests.cfg $VOL_BASE_DIR/ggsn-tester/

mkdir $VOL_BASE_DIR/ggsn
cp ../osmo-ggsn-master/osmo-ggsn.cfg $VOL_BASE_DIR/ggsn/

# start container with ggsn in background
docker run	--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		--network sigtran --ip 172.18.0.201 \
		-v $VOL_BASE_DIR/ggsn:/data \
		--name ggsn -d \
		$REPO_USER/osmo-ggsn-master

# start docker container with testsuite in foreground
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network sigtran --ip 172.18.0.202 \
		-v $VOL_BASE_DIR/ggsn-tester:/data \
		$REPO_USER/ggsn-test

# stop GGSN after test has completed
docker container stop ggsn

rm -rf $WORKSPACE/logs
mkdir -p $WORKSPACE/logs
cp -a $VOL_BASE_DIR/* $WORKSPACE/logs/
#rm -rf $VOL_BASE_DIR
