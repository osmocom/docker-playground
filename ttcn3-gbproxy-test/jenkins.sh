#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-gbproxy-$IMAGE_SUFFIX" \
	"ttcn3-gbproxy-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/gbproxy-tester
# if we don't change permissions, dumpcap fails to write (despite starting it as root!)
chmod a+w $VOL_BASE_DIR/gbproxy-tester

cp GBProxy_Tests.cfg $VOL_BASE_DIR/gbproxy-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/gbproxy-tester/GBProxy_Tests.cfg"

mkdir $VOL_BASE_DIR/gbproxy
cp osmo-gbproxy.cfg $VOL_BASE_DIR/gbproxy/

mkdir $VOL_BASE_DIR/unix

network_create
network_replace_subnet_in_configs

echo Starting container with gbproxy
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/gbproxy:/data \
		--name ${BUILD_TAG}-gbproxy -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-gbproxy-$IMAGE_SUFFIX \
		/bin/sh -c "osmo-gbproxy -c /data/osmo-gbproxy.cfg >/data/osmo-gbproxy.log 2>&1"

echo Starting container with gbproxy testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=$SUB4_PREFIX.$SUBNET.10" \
		-e "OSMO_SUT_PORT=4246" \
		-v $VOL_BASE_DIR/gbproxy-tester:/data \
		--name ${BUILD_TAG}-ttcn3-gbproxy-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-gbproxy-test $@
