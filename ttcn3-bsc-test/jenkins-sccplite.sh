#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-bsc-$IMAGE_SUFFIX" \
	"osmo-bts-$IMAGE_SUFFIX" \
	"ttcn3-bsc-test"

#Make sure NET_NAME doesn't clash with the AoIP BSC test
NET_NAME=ttcn3-bsc_sccplite-test

mkdir $VOL_BASE_DIR/bsc-tester
cp sccplite/BSC_Tests.cfg $VOL_BASE_DIR/bsc-tester/

mkdir $VOL_BASE_DIR/bsc
cp sccplite/osmo-bsc.cfg $VOL_BASE_DIR/bsc/

SUBNET=12
network_create $SUBNET

# Disable stats testing until libosmocore release > 1.4.0
if [ "$IMAGE_SUFFIX" = "latest" ]; then
	sed -i "s/^StatsD_Checker.mp_enable_stats.*/StatsD_Checker.mp_enable_stats := false;/" $VOL_BASE_DIR/bsc-tester/BSC_Tests.cfg
	sed -i "s/stats interval 0//" $VOL_BASE_DIR/bsc/osmo-bsc.cfg
	sed -i "s/flush-period 1//" $VOL_BASE_DIR/bsc/osmo-bsc.cfg
fi

echo Starting container with BSC
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/bsc:/data \
		--name ${BUILD_TAG}-bsc -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-bsc-$IMAGE_SUFFIX

for i in `seq 0 2`; do
	echo Starting container with OML for BTS$i
	docker run	--rm \
			$(docker_network_params $SUBNET 10$i) \
			--ulimit core=-1 \
			--name ${BUILD_TAG}-bts$i -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-bts-$IMAGE_SUFFIX \
			/bin/sh -c "/usr/local/bin/respawn.sh osmo-bts-omldummy 172.18.12.20 $((i + 1234)) 1 >>/data/osmo-bts-omldummy-${i}.log 2>&1"
done

echo Starting container with BSC testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/bsc-tester:/data \
		--name ${BUILD_TAG}-ttcn3-bsc-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-bsc-test

echo Stopping containers
for i in `seq 0 2`; do
	docker container kill ${BUILD_TAG}-bts$i
done
docker container kill ${BUILD_TAG}-bsc

network_remove
collect_logs
