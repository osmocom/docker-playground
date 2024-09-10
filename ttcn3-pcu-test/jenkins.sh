#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-pcu-$IMAGE_SUFFIX" \
	"ttcn3-pcu-test"

set_clean_up_trap
set -e

set_pcuif_version() {
	if osmo_repo_is_2023q1; then
		sed -i 's/PCUIF_Types.mp_pcuif_version := 13/PCUIF_Types.mp_pcuif_version := 10/g' $1
	fi

	if osmo_repo_is_latest; then
		sed -i 's/PCUIF_Types.mp_pcuif_version := 13/PCUIF_Types.mp_pcuif_version := 12/g' $1
	fi
}

mkdir $VOL_BASE_DIR/pcu-tester
mkdir $VOL_BASE_DIR/pcu-tester/unix
cp PCU_Tests.cfg $VOL_BASE_DIR/pcu-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/pcu-tester/PCU_Tests.cfg"
set_pcuif_version "$VOL_BASE_DIR/pcu-tester/PCU_Tests.cfg"

mkdir $VOL_BASE_DIR/pcu
mkdir $VOL_BASE_DIR/pcu/unix
cp osmo-pcu.cfg $VOL_BASE_DIR/pcu/

mkdir $VOL_BASE_DIR/unix

network_create
network_replace_subnet_in_configs

echo Starting container with PCU
docker run	--rm \
		$(docker_network_params $SUBNET 101) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/pcu:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-pcu -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-pcu-$IMAGE_SUFFIX \
		/bin/sh -c "/usr/local/bin/respawn.sh osmo-pcu -c /data/osmo-pcu.cfg >>/data/osmo-pcu.log 2>&1"

echo Starting container with PCU testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=$SUB4_PREFIX.$SUBNET.101" \
		-e "OSMO_SUT_PORT=4240" \
		-v $VOL_BASE_DIR/pcu-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-ttcn3-pcu-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-pcu-test
