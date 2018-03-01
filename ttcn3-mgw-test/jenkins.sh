#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-mgw-$IMAGE_SUFFIX" \
	"ttcn3-mgw-test"

set_clean_up_trap
set -e

ADD_TTCN_RUN_OPTS=""
ADD_TTCN_RUN_CMD=""
ADD_TTCN_VOLUMES=""
ADD_MGW_VOLUMES=""
ADD_MGW_ARGS=""

if [ "x$1" = "x-h" ]; then
	ADD_TTCN_RUN_OPTS="-ti"
	ADD_TTCN_RUN_CMD="bash"
	if [ -d "$2" ]; then
		ADD_TTCN_VOLUMES="$ADD_TTCN_VOLUMES -v $2:/osmo-ttcn3-hacks"
	fi
	if [ -d "$3" ]; then
		ADD_MGW_RUN_CMD="sleep 9999999"
		ADD_MGW_VOLUMES="$ADD_MGW_VOLUMES -v $3:/src"
		ADD_MGW_RUN_OPTS="--privileged"
	fi
fi

mkdir $VOL_BASE_DIR/mgw-tester
cp MGCP_Test.cfg $VOL_BASE_DIR/mgw-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/mgw-tester/MGCP_Test.cfg"

mkdir $VOL_BASE_DIR/mgw
cp osmo-mgw.cfg $VOL_BASE_DIR/mgw/

SUBNET=4
network_create $SUBNET

# start container with mgw in background
docker run	--rm \
		$(docker_network_params $SUBNET 180) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/mgw:/data \
		$ADD_MGW_VOLUMES \
		--name ${BUILD_TAG}-mgw -d \
		$DOCKER_ARGS \
		$ADD_MGW_RUN_OPTS \
		$REPO_USER/osmo-mgw-$IMAGE_SUFFIX \
		$ADD_MGW_RUN_CMD

# start docker container with testsuite in foreground
docker run	--rm \
		$(docker_network_params $SUBNET 181) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/mgw-tester:/data \
		$ADD_TTCN_VOLUMES \
		-e "TTCN3_PCAP_PATH=/data" \
		--name ${BUILD_TAG}-ttcn3-mgw-test \
		$DOCKER_ARGS \
		$ADD_TTCN_RUN_OPTS \
		$REPO_USER/ttcn3-mgw-test \
		$ADD_TTCN_RUN_CMD
