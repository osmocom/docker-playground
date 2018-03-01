#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"osmo-sgsn-$IMAGE_SUFFIX" \
	"ttcn3-sgsn-test"

set_clean_up_trap
set -e

ADD_TTCN_RUN_OPTS=""
ADD_TTCN_RUN_CMD=""
ADD_TTCN_VOLUMES=""
SGSN_RUN_CMD="osmo-sgsn -c /data/osmo-sgsn.cfg"
ADD_SGSN_VOLUMES=""
ADD_SGSN_ARGS=""
ADD_SGSN_RUN_OPTS=""

if [ "x$1" = "x-h" ]; then
	ADD_TTCN_RUN_OPTS="-ti"
	ADD_TTCN_RUN_CMD="bash"
	if [ -d "$2" ]; then
		ADD_TTCN_VOLUMES="$ADD_TTCN_VOLUMES -v $2:/osmo-ttcn3-hacks"
	fi
	if [ -d "$3" ]; then
		SGSN_RUN_CMD="sleep 9999999"
		ADD_SGSN_VOLUMES="$ADD_SGSN_VOLUMES -v $3:/src"
		set +x
		echo "

===== ATTENTION =====
Starting the osmo-sgsn-master docker image in hacking mode.
That means to launch the SGSN, you need to attach to it and start it manually:

  docker exec -ti nonjenkins-sgsn bash
  /# make

=====
"
		set -x
	fi
else
	ADD_TTCN_RUN_CMD="$@"
fi

SUBNET=8
network_create $SUBNET

mkdir $VOL_BASE_DIR/sgsn-tester
cp SGSN_Tests.cfg $VOL_BASE_DIR/sgsn-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/sgsn-tester/SGSN_Tests.cfg"

mkdir $VOL_BASE_DIR/sgsn
cp osmo-sgsn.cfg $VOL_BASE_DIR/sgsn/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/unix

echo Starting container with STP
docker run	--rm \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with SGSN
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/sgsn:/data \
		$ADD_SGSN_VOLUMES \
		--name ${BUILD_TAG}-sgsn -d \
		$DOCKER_ARGS \
		$ADD_SGSN_RUN_OPTS \
		$REPO_USER/osmo-sgsn-$IMAGE_SUFFIX \
		$SGSN_RUN_CMD

echo Starting container with SGSN testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=172.18.$SUBNET.10" \
		-e "OSMO_SUT_PORT=4245" \
		-v $VOL_BASE_DIR/sgsn-tester:/data \
		$ADD_TTCN_VOLUMES \
		--name ${BUILD_TAG}-ttcn3-sgsn-test \
		$DOCKER_ARGS \
		$ADD_TTCN_RUN_OPTS \
		$REPO_USER/ttcn3-sgsn-test \
		$ADD_TTCN_RUN_CMD
