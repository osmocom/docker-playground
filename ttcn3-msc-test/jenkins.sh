#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"osmo-msc-$IMAGE_SUFFIX" \
	"ttcn3-msc-test"

set_clean_up_trap
set -e

SUBNET=20
network_create $SUBNET

ADD_TTCN_RUN_OPTS=""
ADD_TTCN_RUN_CMD=""
ADD_TTCN_VOLUMES=""
ADD_MSC_VOLUMES=""
ADD_MSC_RUN_OPTS=""
MSC_RUN_CMD="/bin/sh -c \"osmo-msc -c /data/osmo-msc.cfg >>/data/osmo-msc.log 2>&1\""

if [ "x$1" = "x-h" ]; then
	ADD_TTCN_RUN_OPTS="-ti"
	ADD_TTCN_RUN_CMD="bash"
	if [ -d "$2" ]; then
		ADD_TTCN_VOLUMES="$ADD_TTCN_VOLUMES -v $2:/osmo-ttcn3-hacks"
	fi
	if [ -d "$3" ]; then
		ADD_MSC_VOLUMES="$ADD_MSC_VOLUMES -v $3:/src"
		MSC_RUN_CMD="sleep 9999999"
		#ADD_MSC_RUN_OPTS="--privileged"
	fi
fi

mkdir $VOL_BASE_DIR/msc-tester
mkdir $VOL_BASE_DIR/msc-tester/unix
cp MSC_Tests.cfg $VOL_BASE_DIR/msc-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/msc-tester/MSC_Tests.cfg"

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/msc
mkdir $VOL_BASE_DIR/msc/unix
cp osmo-msc.cfg $VOL_BASE_DIR/msc/

mkdir $VOL_BASE_DIR/unix

echo Starting container with STP
docker run	--rm \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with MSC
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/msc:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		$ADD_MSC_VOLUMES \
		--name ${BUILD_TAG}-msc -d \
		$DOCKER_ARGS \
		$ADD_MSC_RUN_OPTS \
		$REPO_USER/osmo-msc-$IMAGE_SUFFIX \
		$MSC_RUN_CMD

echo Starting container with MSC testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=172.18.$SUBNET.10" \
		-e "OSMO_SUT_PORT=4254" \
		-v $VOL_BASE_DIR/msc-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		$ADD_TTCN_VOLUMES \
		--name ${BUILD_TAG}-ttcn3-msc-test \
		$DOCKER_ARGS \
		$ADD_TTCN_RUN_OPTS \
		$REPO_USER/ttcn3-msc-test \
		$ADD_TTCN_RUN_CMD
