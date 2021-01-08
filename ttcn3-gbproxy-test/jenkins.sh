#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-sgsn-$IMAGE_SUFFIX" \
	"ttcn3-gbproxy-test"

SUBNET=24
network_create $SUBNET

mkdir $VOL_BASE_DIR/gbproxy-tester
# if we don't change permissions, dumpcap fails to write (despite starting it as root!)
chmod a+w $VOL_BASE_DIR/gbproxy-tester

cp GBProxy_Tests.cfg $VOL_BASE_DIR/gbproxy-tester/

mkdir $VOL_BASE_DIR/sgsn
cp osmo-gbproxy.cfg $VOL_BASE_DIR/sgsn/

# Disable features not in latest yet
if [ "$IMAGE_SUFFIX" = "latest" ]; then
	true;
fi

mkdir $VOL_BASE_DIR/unix

echo Starting container with SGSN
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/sgsn:/data \
		--name ${BUILD_TAG}-sgsn -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-sgsn-$IMAGE_SUFFIX \
		/bin/sh -c "osmo-gbproxy -c /data/osmo-gbproxy.cfg >/data/osmo-gbproxy.log 2>&1"

echo Starting container with SGSN testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/gbproxy-tester:/data \
		--name ${BUILD_TAG}-ttcn3-gbproxy-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-gbproxy-test $@

echo Starting container to merge logs
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/gbproxy-tester:/data \
		--name ${BUILD_TAG}-ttcn3-gbproxy-test-logmerge \
		--entrypoint /osmo-ttcn3-hacks/log_merge.sh GBProxy_Tests --rm \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-gbproxy-test

echo Stopping containers
docker container kill ${BUILD_TAG}-sgsn

network_remove
collect_logs
