#!/bin/sh

. ../jenkins-common.sh

VOL_BASE_DIR=`mktemp -d`
mkdir $VOL_BASE_DIR/ggsn-tester
cp GGSN_Tests.cfg $VOL_BASE_DIR/ggsn-tester/

mkdir $VOL_BASE_DIR/ggsn
cp osmo-ggsn.cfg $VOL_BASE_DIR/ggsn/

network_create 172.18.3.0/24

# start container with ggsn in background
docker run	--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		--network $NET_NAME --ip 172.18.3.201 \
		-v $VOL_BASE_DIR/ggsn:/data \
		--name ${BUILD_TAG}-ggsn -d \
		$REPO_USER/osmo-ggsn-master

# start docker container with testsuite in foreground
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network $NET_NAME --ip 172.18.3.202 \
		-v $VOL_BASE_DIR/ggsn-tester:/data \
		--name ${BUILD_TAG}-ggsn-test \
		$REPO_USER/ggsn-test

# stop GGSN after test has completed
docker container stop ${BUILD_TAG}-ggsn

network_remove

rm -rf $WORKSPACE/logs
mkdir -p $WORKSPACE/logs
cp -a $VOL_BASE_DIR/* $WORKSPACE/logs/
