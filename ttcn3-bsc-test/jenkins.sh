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

network_create
network_replace_subnet_in_configs

echo Starting container with STP
docker run	--rm \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-e LIBOSMO_IO_BACKEND=IO_URING --privileged \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with BSC
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-e LIBOSMO_IO_BACKEND=IO_URING --privileged \
		-v $VOL_BASE_DIR/bsc:/data \
		--name ${BUILD_TAG}-bsc -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-bsc-$IMAGE_SUFFIX

BTS_FEATURES="-fCCN,EGPRS,GPRS,IPv6_NSVC,PAGING_COORDINATION,OSMUX"

for i in "0 1" "1 1" "2 4"; do
	set -- $i # convert the {BTS, TRXN} "tuple" into the param args $1 $2
	echo "Starting container with OML for BTS$1 (TRXN = $2)"
	docker run	--rm \
			$(docker_network_params $SUBNET 10$1) \
			--ulimit core=-1 \
			-e LIBOSMO_IO_BACKEND=IO_URING --privileged \
			-v $VOL_BASE_DIR/bts-omldummy:/data \
			--name ${BUILD_TAG}-bts$1 -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-bts-$IMAGE_SUFFIX \
			/bin/sh -c "/usr/local/bin/respawn.sh \
				osmo-bts-omldummy \
					$BTS_FEATURES \
					$SUB4_PREFIX.$SUBNET.20 \
					$(($1 + 1234)) \
					$2 \
				>>/data/osmo-bts-omldummy-$1.log 2>&1"
done

# Give OsmoBSC time to connect to OsmoSTP, so BSSMAP RESET from the testsuite
# doesn't fail in OsmoSTP with "MTP-TRANSFER.req for DPC 187: no route!"
sleep 1

echo Starting container with BSC testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=$SUB4_PREFIX.$SUBNET.20" \
		-e "OSMO_SUT_PORT=4242" \
		-v $VOL_BASE_DIR/bsc-tester:/data \
		--name ${BUILD_TAG}-ttcn3-bsc-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-bsc-test
