#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-pcu-$IMAGE_SUFFIX" \
	"ttcn3-pcu-test"

set_clean_up_trap
set -e

SUBNET=13
network_create $SUBNET

mkdir $VOL_BASE_DIR/pcu-tester
mkdir $VOL_BASE_DIR/pcu-tester/unix
cp PCU_Tests.cfg $VOL_BASE_DIR/pcu-tester/

# Disable until osmo-pcu release > 0.9.0
if image_suffix_is_latest; then
	cfg="$VOL_BASE_DIR/pcu-tester/PCU_Tests.cfg"
	sed -i "s/^PCUIF_Components.mp_send_all_data_ind.*/PCUIF_Components.mp_send_all_data_ind := false;/" "$cfg"
	sed -i "s/^PCU_Tests.mp_osmo_pcu_newer_than_0_9_0.*/PCU_Tests.mp_osmo_pcu_newer_than_0_9_0 := false;/" "$cfg"
else
	sed "/PCU_Tests.mp_ctrl_neigh_ip/d" -i "$VOL_BASE_DIR/pcu-tester/PCU_Tests.cfg"
fi

mkdir $VOL_BASE_DIR/pcu
mkdir $VOL_BASE_DIR/pcu/unix
cp osmo-pcu.cfg $VOL_BASE_DIR/pcu/
# Disable until osmo-pcu release > 0.9.0
if image_suffix_is_master; then
	sed "/neighbor resolution/d" -i "$VOL_BASE_DIR/pcu/osmo-pcu.cfg"
fi

mkdir $VOL_BASE_DIR/unix

echo Starting container with PCU
docker run	--rm \
		$(docker_network_params $SUBNET 101) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/pcu:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-pcu -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-pcu-$IMAGE_SUFFIX \
		/bin/sh -c "/usr/local/bin/respawn.sh osmo-pcu -c /data/osmo-pcu.cfg -i 172.18.13.10 >>/data/osmo-pcu.log 2>&1"

echo Starting container with PCU testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/pcu-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-ttcn3-pcu-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-pcu-test
