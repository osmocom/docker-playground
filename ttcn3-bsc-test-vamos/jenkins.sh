#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"osmo-bsc-$IMAGE_SUFFIX" \
	"osmo-bts-$IMAGE_SUFFIX" \
	"ttcn3-bsc-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/bsc-tester
cp BSC_Tests.cfg $VOL_BASE_DIR/bsc-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/bsc-tester/BSC_Tests.cfg"

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/bsc
cp osmo-bsc.cfg $VOL_BASE_DIR/bsc/

mkdir $VOL_BASE_DIR/bts-omldummy

SUBNET=31
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

echo Starting container with BSC
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/bsc:/data \
		--name ${BUILD_TAG}-bsc -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-bsc-$IMAGE_SUFFIX

BTS_FEATURES="-fCCN,EGPRS,GPRS,IPv6_NSVC,PAGING_COORDINATION,VAMOS"
# Disable until libosmocore release > 1.7.0
if image_suffix_is_master; then
	BTS_FEATURES="${BTS_FEATURES},OSMUX"
fi

for i in `seq 0 2`; do
	echo Starting container with OML for BTS$i
	docker run	--rm \
			$(docker_network_params $SUBNET 10$i) \
			--ulimit core=-1 \
			-v $VOL_BASE_DIR/bts-omldummy:/data \
			--name ${BUILD_TAG}-bts$i -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-bts-$IMAGE_SUFFIX \
			/bin/sh -c "/usr/local/bin/respawn.sh osmo-bts-omldummy $BTS_FEATURES 172.18.31.20 $((i + 1234)) 1 >>/data/osmo-bts-omldummy-${i}.log 2>&1"
done

echo Starting container with BSC testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=172.18.$SUBNET.20" \
		-e "OSMO_SUT_PORT=4242" \
		-v $VOL_BASE_DIR/bsc-tester:/data \
		--name ${BUILD_TAG}-ttcn3-bsc-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-bsc-test
