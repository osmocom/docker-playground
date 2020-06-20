#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-ggsn-$IMAGE_SUFFIX" \
	"ttcn3-ggsn-test"

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
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/ggsn:/data \
		--name ${BUILD_TAG}-ggsn -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-ggsn-$IMAGE_SUFFIX \
		/bin/sh -c "osmo-ggsn -c /data/osmo-ggsn.cfg >/data/osmo-ggsn.log 2>&1"

# start docker container with testsuite in foreground
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network $NET_NAME --ip 172.18.3.202 \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/ggsn-tester:/data \
		-e "TTCN3_PCAP_PATH=/data" \
		--name ${BUILD_TAG}-ggsn-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-ggsn-test

# stop GGSN after test has completed
docker container stop ${BUILD_TAG}-ggsn

network_remove
collect_logs
