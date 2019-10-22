#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-stretch-build" \
	"osmo-remsim-$IMAGE_SUFFIX" \
	"ttcn3-remsim-test"

start_server() {
	echo Starting container with osmo-remsim-server
	docker run	--rm \
			--network $NET_NAME --ip 172.18.17.20 \
			-v $VOL_BASE_DIR/server:/data \
			--name ${BUILD_TAG}-server -d \
			$REPO_USER/osmo-remsim-$IMAGE_SUFFIX \
			osmo-remsim-server
}

start_bankd() {
	echo Starting container with osmo-remsim-bankd
	docker run	--rm \
			--network $NET_NAME --ip 172.18.17.30 \
			-v $VOL_BASE_DIR/bankd:/data \
			--name ${BUILD_TAG}-bankd -d \
			$REPO_USER/osmo-remsim-$IMAGE_SUFFIX \
			osmo-remsim-bankd -i 172.18.17.10
}

start_client() {
	echo Starting container with osmo-remsim-client
	docker run	--rm \
			--network $NET_NAME --ip 172.18.17.40 \
			-v $VOL_BASE_DIR/client:/data \
			--name ${BUILD_TAG}-client-d \
			$REPO_USER/osmo-remsim-$IMAGE_SUFFIX \
			osmo-remsim-client
}



start_testsuite() {
	echo Starting container with REMSIM testsuite
	docker run	--rm \
			--network $NET_NAME --ip 172.18.17.10 \
			-e "TTCN3_PCAP_PATH=/data" \
			-v $VOL_BASE_DIR/remsim-tester:/data \
			--name ${BUILD_TAG}-ttcn3-remsim-test \
			$REPO_USER/ttcn3-remsim-test
}

network_create 172.18.17.0/24

mkdir $VOL_BASE_DIR/remsim-tester

mkdir $VOL_BASE_DIR/server

mkdir $VOL_BASE_DIR/bankd
cp bankd/bankd_pcsc_slots.csv $VOL_BASE_DIR/bankd/

mkdir $VOL_BASE_DIR/client


# 1) server test suite
start_server
cp REMSIM_Tests.cfg $VOL_BASE_DIR/remsim-tester/
start_testsuite
docker container kill ${BUILD_TAG}-server

# 2) bankd test suite
echo "Changing to bankd configuration"
start_bankd
cp bankd/REMSIM_Tests.cfg $VOL_BASE_DIR/remsim-tester/
start_testsuite
docker container kill ${BUILD_TAG}-bankd

# 3) client test suite
#echo "Changing to client configuration"
#start_client
#cp client/REMSIM_Tests.cfg $VOL_BASE_DIR/remsim-tester/
#start_testsuite
#docker container kill ${BUILD_TAG}-client

network_remove
collect_logs