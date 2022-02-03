#!/bin/sh

. ../jenkins-common.sh

KERNEL_TEST="${KERNEL_TEST:-0}"
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"open5gs-$IMAGE_SUFFIX" \
	"ttcn3-ggsn-test"

set_clean_up_trap
set -e

#Make sure NET_NAME doesn't clash with the AoIP BSC test
NET_NAME=ttcn3-ggsn-test-ogs

mkdir $VOL_BASE_DIR/ggsn-tester
cp ogs/GGSN_Tests.cfg $VOL_BASE_DIR/ggsn-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/ggsn-tester/GGSN_Tests.cfg"

mkdir $VOL_BASE_DIR/ggsn
cp ogs/smfd.yaml $VOL_BASE_DIR/ggsn/
cp ogs/upfd.yaml $VOL_BASE_DIR/ggsn/
cp ogs/freediameter.conf $VOL_BASE_DIR/ggsn/
cp ogs/upfd.sh $VOL_BASE_DIR/ggsn/
cp ogs/upfd-setup.sh $VOL_BASE_DIR/ggsn/

SUBNET=3
network_create $SUBNET

# start container with ggsn (smf+upf) in background
docker run	--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/ggsn:/data \
		--name ${BUILD_TAG}-ggsn-ogs-smf -d \
		$DOCKER_ARGS \
		$(docker_network_params $SUBNET 201) \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		/bin/sh -c "open5gs-smfd -c /data/smfd.yaml >/data/open5gs-smfd.out 2>&1"

docker run	--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/ggsn:/data \
		--name ${BUILD_TAG}-ggsn-ogs-upf -d \
		$DOCKER_ARGS \
		$(docker_network_params $SUBNET 222) \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		/bin/sh -c "/data/upfd.sh -c /data/upfd.yaml >/data/open5gs-upfd.out 2>&1"

# start docker container with testsuite in foreground
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		$(docker_network_params $SUBNET 202) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/ggsn-tester:/data \
		-e "TTCN3_PCAP_PATH=/data" \
		--name ${BUILD_TAG}-ggsn-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-ggsn-test

