#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"osmo-smlc-$IMAGE_SUFFIX" \
	"ttcn3-smlc-test"

<<<<<<< HEAD
set_clean_up_trap
set -e

||||||| parent of 6105d7c (ttcn3-smlc-test: manual invocation)
=======
ADD_TTCN_RUN_OPTS=""
ADD_TTCN_RUN_CMD=""
ADD_TTCN_VOLUMES=""
ADD_SMLC_VOLUMES=""
ADD_SMLC_ARGS=""

if [ "x$1" = "x-h" ]; then
	ADD_TTCN_RUN_OPTS="-ti"
	ADD_TTCN_RUN_CMD="bash"
	if [ -d "$2" ]; then
		ADD_TTCN_VOLUMES="$ADD_TTCN_VOLUMES -v $2:/osmo-ttcn3-hacks"
	fi
	if [ -d "$3" ]; then
		ADD_SMLC_RUN_CMD="sleep 9999999"
		ADD_SMLC_VOLUMES="$ADD_SMLC_VOLUMES -v $3:/src"
	fi
fi

>>>>>>> 6105d7c (ttcn3-smlc-test: manual invocation)
mkdir $VOL_BASE_DIR/smlc-tester
cp SMLC_Tests.cfg $VOL_BASE_DIR/smlc-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/smlc-tester/SMLC_Tests.cfg"

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/smlc
cp osmo-smlc.cfg $VOL_BASE_DIR/smlc/

SUBNET=23
network_create $SUBNET

echo Starting container with STP
docker run	--rm \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		--ulimit core=-1 \
		$DOCKER_ARGS \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with SMLC
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/smlc:/data \
		$ADD_SMLC_VOLUMES \
		--name ${BUILD_TAG}-smlc -d \
		$DOCKER_ARGS \
		$ADD_SMLC_ARGS \
		$REPO_USER/osmo-smlc-$IMAGE_SUFFIX \
		$ADD_SMLC_RUN_CMD

echo Starting container with SMLC testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/smlc-tester:/data \
		$ADD_TTCN_VOLUMES \
		--name ${BUILD_TAG}-ttcn3-smlc-test \
		$ADD_TTCN_RUN_OPTS \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-smlc-test \
		$ADD_TTCN_RUN_CMD
