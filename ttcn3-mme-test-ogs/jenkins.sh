#!/bin/sh

. ../jenkins-common.sh

IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"open5gs-$IMAGE_SUFFIX" \
	"ttcn3-mme-test-ogs"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/mme-tester
cp ogs/MME_Tests.cfg $VOL_BASE_DIR/mme-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/mme-tester/MME_Tests.cfg"

mkdir $VOL_BASE_DIR/mme
cp ogs/open5gs-*-$IMAGE_SUFFIX.yaml $VOL_BASE_DIR/mme/
cp ogs/freediameter.conf $VOL_BASE_DIR/mme/
cp ogs/mme.sh $VOL_BASE_DIR/mme/

network_create
network_replace_subnet_in_configs

# start container with mme in background
docker run	--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/mme:/data \
		--name ${BUILD_TAG}-ogs-mme -d \
		$DOCKER_ARGS \
		$(docker_network_params $SUBNET 201) \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		/bin/sh -c "open5gs-mmed -c /data/open5gs-mme-$IMAGE_SUFFIX.yaml >/data/open5gs-mmed.out 2>&1"

# start docker container with testsuite in foreground
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		$(docker_network_params $SUBNET 202) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/mme-tester:/data \
		-e "TTCN3_PCAP_PATH=/data" \
		--name ${BUILD_TAG}-mme-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-mme-test-ogs
