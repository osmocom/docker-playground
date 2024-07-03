#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
# Always require osmo-stp-master since is the only with sccp_demo_user installed
docker_images_require \
	"osmo-stp-master" \
	"ttcn3-sccp-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/sccp-tester
cp SCCP_Tests.cfg $VOL_BASE_DIR/sccp-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/sccp-tester/SCCP_Tests.cfg"

mkdir $VOL_BASE_DIR/sccp
cp sccp_demo_user.cfg $VOL_BASE_DIR/sccp/

network_create
network_replace_subnet_in_configs

echo Starting container with sccp_demo_user
docker run	--rm \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/sccp:/data \
		--name ${BUILD_TAG}-stp -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-stp-master \
		/bin/sh -c "sccp_demo_user \
			-l $SUB4_PREFIX.$SUBNET.200 \
			-r $SUB4_PREFIX.$SUBNET.203 \
			-C /data/sccp_demo_user.cfg \
			>>/data/sccp_demo_user.log 2>&1"


echo Starting container with SCCP testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/sccp-tester:/data \
		--name ${BUILD_TAG}-ttcn3-sccp-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-sccp-test
