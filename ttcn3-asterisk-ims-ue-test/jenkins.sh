#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"asterisk-$IMAGE_SUFFIX" \
	"ttcn3-asterisk-ims-ue-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/asterisk-ims-ue-tester
mkdir $VOL_BASE_DIR/asterisk-ims-ue-tester/unix
cp Asterisk_Tests.cfg $VOL_BASE_DIR/asterisk-ims-ue-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/asterisk-ims-ue-tester/Asterisk_Tests.cfg"

mkdir $VOL_BASE_DIR/asterisk
# TODO: copy Asterisk config files:
cp asterisk/*.conf $VOL_BASE_DIR/asterisk/

network_create
network_replace_subnet_in_configs

echo Starting container with Asterisk
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/asterisk:/data \
		--name ${BUILD_TAG}-asterisk -ti \
		$DOCKER_ARGS \
		$REPO_USER/asterisk-$IMAGE_SUFFIX \
		/bin/bash
		#/bin/sh -c "/usr/sbin/asterisk -C /data/asterisk.cfg -f -g -vvvvv -ddddd >>/data/asterisk.log 2>&1"
exit 0
echo Starting container with Asterisk testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/asterisk-ims-ue-tester:/data \
		--name ${BUILD_TAG}-ttcn3-asterisk-ims-ue-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-asterisk-ims-ue-test
