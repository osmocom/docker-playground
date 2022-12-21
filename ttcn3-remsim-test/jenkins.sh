#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-remsim-$IMAGE_SUFFIX" \
	"ttcn3-remsim-test"

set_clean_up_trap
set -e

start_server() {
	echo Starting container with osmo-remsim-server
	docker run	--rm \
			$(docker_network_params $SUBNET 20) \
			--ulimit core=-1 \
			-v $VOL_BASE_DIR/server:/data \
			--name ${BUILD_TAG}-server -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-remsim-$IMAGE_SUFFIX \
			/bin/sh -c "osmo-remsim-server >/data/osmo-remsim-server.log 2>&1"
}

start_bankd() {
	echo Starting container with osmo-remsim-bankd
	docker run	--rm \
			$(docker_network_params $SUBNET 30) \
			--ulimit core=-1 \
			-v $VOL_BASE_DIR/bankd:/data \
			--name ${BUILD_TAG}-bankd -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-remsim-$IMAGE_SUFFIX \
			/bin/sh -c "pcscd; \
				osmo-remsim-bankd \
					-i 172.18.$SUBNET.10 \
					>/data/osmo-remsim-bankd.log 2>&1"
}

start_client() {
	echo Starting container with osmo-remsim-client
	docker run	--rm \
			$(docker_network_params $SUBNET 40) \
			--ulimit core=-1 \
			-v $VOL_BASE_DIR/client:/data \
			--name ${BUILD_TAG}-client-d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-remsim-$IMAGE_SUFFIX \
			/bin/sh -c "osmo-remsim-client-shell >/data/osmo-remsim-client.log 2>&1"
}



start_testsuite() {
	echo Starting container with REMSIM testsuite
	docker run	--rm \
			$(docker_network_params $SUBNET 10) \
			--ulimit core=-1 \
			-e "TTCN3_PCAP_PATH=/data" \
			-v $VOL_BASE_DIR/remsim-tester:/data \
			--name ${BUILD_TAG}-ttcn3-remsim-test \
			$DOCKER_ARGS \
			$REPO_USER/ttcn3-remsim-test
}

network_create

mkdir $VOL_BASE_DIR/remsim-tester

mkdir $VOL_BASE_DIR/server

mkdir $VOL_BASE_DIR/bankd
cp bankd/bankd_pcsc_slots.csv $VOL_BASE_DIR/bankd/

mkdir $VOL_BASE_DIR/client


# 1) server test suite
cp REMSIM_Tests.cfg $VOL_BASE_DIR/remsim-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/remsim-tester/REMSIM_Tests.cfg"
network_replace_subnet_in_configs
start_server
start_testsuite
docker container kill ${BUILD_TAG}-server

# 2) bankd test suite
echo "Changing to bankd configuration"
cp bankd/REMSIM_Tests.cfg $VOL_BASE_DIR/remsim-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/remsim-tester/REMSIM_Tests.cfg"
network_replace_subnet_in_configs
start_bankd
start_testsuite
docker container kill ${BUILD_TAG}-bankd

# 3) client test suite
echo "Changing to client configuration"
cp client/REMSIM_Tests.cfg $VOL_BASE_DIR/remsim-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/remsim-tester/REMSIM_Tests.cfg"
network_replace_subnet_in_configs
start_client
start_testsuite
