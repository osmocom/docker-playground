#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-stretch-build" \
	"debian-stretch-titan" \
	"ttcn3-ggsn-test"

mkdir $VOL_BASE_DIR/ggsn-tester
cp GGSN_Tests.cfg $VOL_BASE_DIR/ggsn-tester/

mkdir $VOL_BASE_DIR/vpp
cp vpp/init.conf $VOL_BASE_DIR/vpp/
cp vpp/startup.conf $VOL_BASE_DIR/vpp/

mkdir $VOL_BASE_DIR/ergw
cp ergw/sys.config $VOL_BASE_DIR/ergw/

# SGi + S5/S8-U + S5/S8-C
network_create 172.20.16.0/24

# PFCP Between PGW-U and PGW-C
NET_NAME_PFCP=$SUITE_NAME-pfcp
network_create 172.21.16.0/24 $NET_NAME_PFCP

NET_NAME_SGI=$SUITE_NAME-sgi
network_create 172.20.15.0/24 $NET_NAME_SGI

# start container with upf in background
docker create	--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		--network $NET_NAME_PFCP \
		-v $VOL_BASE_DIR/vpp:/data \
		--name ${BUILD_TAG}-vpp \
		--entrypoint="" \
		quay.io/travelping/upf:feature-2001-upf_v20.01-141-g6864fd594_debug \
		/bin/sh -c "/usr/bin/vpp -c /data/startup.conf >/data/vpp_console.log 2>&1"
docker network connect $NET_NAME_SGI ${BUILD_TAG}-vpp
docker network connect $NET_NAME ${BUILD_TAG}-vpp
docker start ${BUILD_TAG}-vpp

# start container with ergw in background
docker create	--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		--network $NET_NAME_PFCP --ip 172.21.16.2 \
		-v $VOL_BASE_DIR/ergw:/config/ergw-c-node \
		-v $VOL_BASE_DIR/ergw:/data \
		--name ${BUILD_TAG}-ergw \
		--entrypoint="" \
		quay.io/travelping/ergw-c-node:master_2.2.0-52-g53265c1 \
		/bin/sh -c "/docker-entrypoint.sh /opt/ergw-c-node/bin/ergw-c-node foreground >/data/ergw_console.log 2>&1"
docker network connect $NET_NAME --ip 172.20.16.23 ${BUILD_TAG}-ergw
docker start ${BUILD_TAG}-ergw

echo "Press something to continue:"
read line

# start docker container with testsuite in foreground
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network $NET_NAME --ip 172.20.16.202 \
		-v $VOL_BASE_DIR/ggsn-tester:/data \
		-e "TTCN3_PCAP_PATH=/data" \
		--name ${BUILD_TAG}-ggsn-test \
		$REPO_USER/ttcn3-ggsn-test

# stop processes after test has completed
docker container stop ${BUILD_TAG}-ergw
docker container stop ${BUILD_TAG}-vpp

network_remove $NET_NAME_PFCP
network_remove $NET_NAME_SGI
network_remove
collect_logs
