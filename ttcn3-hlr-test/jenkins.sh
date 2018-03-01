#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-hlr-$IMAGE_SUFFIX" \
	"ttcn3-hlr-test"

set_clean_up_trap
set -e

ADD_TTCN_RUN_OPTS=""
ADD_TTCN_RUN_CMD=""
ADD_TTCN_VOLUMES=""
ADD_HLR_VOLUMES=""
ADD_HLR_RUN_OPTS=""
HLR_RUN_CMD="osmo-hlr -c /data/osmo-hlr.cfg"

if [ "x$1" = "x-h" ]; then
	ADD_TTCN_RUN_OPTS="-ti"
	ADD_TTCN_RUN_CMD="bash"
	if [ -d "$2" ]; then
		ADD_TTCN_VOLUMES="$ADD_TTCN_VOLUMES -v $2:/osmo-ttcn3-hacks"
	fi
	if [ -d "$3" ]; then
		ADD_HLR_VOLUMES="$ADD_HLR_VOLUMES -v $3:/src"
		HLR_RUN_CMD="sleep 9999999"
		ADD_HLR_RUN_OPTS="--privileged"
	fi
fi

SUBNET=10
network_create $SUBNET

mkdir $VOL_BASE_DIR/hlr-tester
cp HLR_Tests.cfg $VOL_BASE_DIR/hlr-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/hlr-tester/HLR_Tests.cfg"

mkdir $VOL_BASE_DIR/hlr
cp osmo-hlr.cfg $VOL_BASE_DIR/hlr/

echo Starting container with HLR
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/hlr:/data \
		$ADD_HLR_VOLUMES \
		--name ${BUILD_TAG}-hlr -d \
		$DOCKER_ARGS \
		$ADD_HLR_RUN_OPTS \
		$REPO_USER/osmo-hlr-$IMAGE_SUFFIX \
		$HLR_RUN_CMD

echo Starting container with HLR testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=172.18.$SUBNET.20" \
		-e "OSMO_SUT_PORT=4258" \
		-v $VOL_BASE_DIR/hlr-tester:/data \
		$ADD_TTCN_VOLUMES \
		--name ${BUILD_TAG}-ttcn3-hlr-test \
		$DOCKER_ARGS \
		$ADD_TTCN_RUN_OPTS \
		$REPO_USER/ttcn3-hlr-test \
		$ADD_TTCN_RUN_CMD
