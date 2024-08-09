#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-epdg-$IMAGE_SUFFIX" \
	"ttcn3-epdg-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/epdg-tester
cp EPDG_Tests.cfg $VOL_BASE_DIR/epdg-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/epdg-tester/EPDG_Tests.cfg"

mkdir $VOL_BASE_DIR/epdg
cp osmo-epdg.config $VOL_BASE_DIR/epdg/
cp epdg.sh $VOL_BASE_DIR/epdg/
cp ../common/pipework $VOL_BASE_DIR/epdg/

network_create
network_replace_subnet_in_configs
# gtp_u_kmod has the IP addresses as usual erlang-tuple format. Patch them too:
sed -i -E -e "s/172\,18\,[0-9]{1,3}\,/172,18,$SUBNET,/g" $VOL_BASE_DIR/epdg/osmo-epdg.config
#TODO: Patch IPv6 address once it's supported.

echo Starting container with osmo-epdg
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		-u root \
		-e IMAGE_SUFFIX=$IMAGE_SUFFIX \
		--ulimit core=-1 \
		--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		-v $VOL_BASE_DIR/epdg:/data \
		--name ${BUILD_TAG}-epdg -d \
		$DOCKER_ARGS \
		--sysctl net.ipv4.conf.all.rp_filter=0 \
		--sysctl net.ipv4.conf.default.rp_filter=0 \
		$REPO_USER/osmo-epdg-$IMAGE_SUFFIX \
		/bin/sh -c "/data/epdg.sh >/data/osmo-epdg.log 2>&1"

# Give some time to osmo-epdg to be fully started; it's a bit slow...
sleep 2

echo Starting container with EPDG testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/epdg-tester:/data \
		--name ${BUILD_TAG}-ttcn3-epdg-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-epdg-test
