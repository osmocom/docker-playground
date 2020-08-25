#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-pcu-$IMAGE_SUFFIX" \
	"ttcn3-pcu-test"

set_clean_up_trap
set -e

SUBNET=13
network_create $SUBNET

ADD_TTCN_RUN_OPTS=""
ADD_TTCN_RUN_CMD=""
ADD_TTCN_VOLUMES=""
ADD_PCU_VOLUMES=""
ADD_PCU_ARGS=""

if [ "x$1" = "x-h" ]; then
	ADD_TTCN_RUN_OPTS="-ti"
	ADD_TTCN_RUN_CMD="bash"
	if [ -d "$2" ]; then
		ADD_TTCN_VOLUMES="$ADD_TTCN_VOLUMES -v $2:/osmo-ttcn3-hacks"
	fi
	if [ -d "$3" ]; then
		ADD_PCU_RUN_CMD="sleep 9999999"
		ADD_PCU_VOLUMES="$ADD_PCU_VOLUMES -v $3:/src"
	fi
fi

mkdir $VOL_BASE_DIR/pcu-tester
mkdir $VOL_BASE_DIR/pcu-tester/unix
cp PCU_Tests.cfg $VOL_BASE_DIR/pcu-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/pcu-tester/PCU_Tests.cfg"

mkdir $VOL_BASE_DIR/pcu
mkdir $VOL_BASE_DIR/pcu/unix
cp osmo-pcu.cfg $VOL_BASE_DIR/pcu/

mkdir $VOL_BASE_DIR/unix

echo Starting container with PCU
docker run	--rm \
		$(docker_network_params $SUBNET 101) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/pcu:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		$ADD_PCU_VOLUMES \
		--name ${BUILD_TAG}-pcu -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-pcu-$IMAGE_SUFFIX \
		$ADD_PCU_RUN_CMD

		#/bin/sh -c "/usr/local/bin/respawn.sh osmo-pcu -c /data/osmo-pcu.cfg -i 172.18.13.10 >>/data/osmo-pcu.log 2>&1"

echo Starting container with PCU testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/pcu-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		$ADD_TTCN_VOLUMES \
		--name ${BUILD_TAG}-ttcn3-pcu-test \
		$DOCKER_ARGS \
		$ADD_TTCN_RUN_OPTS \
		$REPO_USER/ttcn3-pcu-test \
		$ADD_TTCN_RUN_CMD
