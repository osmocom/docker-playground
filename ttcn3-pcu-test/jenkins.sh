#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-pcu-$IMAGE_SUFFIX" \
	"ttcn3-pcu-test"

SUBNET=13
network_create $SUBNET

mkdir $VOL_BASE_DIR/pcu-tester
mkdir $VOL_BASE_DIR/pcu-tester/unix
cp PCU_Tests.cfg $VOL_BASE_DIR/pcu-tester/

mkdir $VOL_BASE_DIR/pcu
mkdir $VOL_BASE_DIR/pcu/unix
cp osmo-pcu.cfg $VOL_BASE_DIR/pcu/

mkdir $VOL_BASE_DIR/unix

# TODO: revisit this section every time we tag a new release
if [ "$IMAGE_SUFFIX" = "latest" ]; then
	# PCUIFv10 is not yet supported in the latest release
	sed "/\[MODULE_PARAMETERS\]/ a PCUIF_Types.mp_pcuif_version := 9;" \
		-i "$VOL_BASE_DIR/pcu-tester/PCU_Tests.cfg"
	# Tolerate CellId IE in BVC-RESET for BVCO=0
	sed -e "/\[MODULE_PARAMETERS\]/ a BSSGP_Emulation.mp_tolerate_bvc_reset_cellid := true;" \
	    -e "/\[MODULE_PARAMETERS\]/ a PCU_Tests_NS.mp_tolerate_bvc_reset_cellid := true;" \
		-i "$VOL_BASE_DIR/pcu-tester/PCU_Tests.cfg"

	# Disable stats testing until libosmocore release > 1.4.0
	sed -i "s/^StatsD_Checker.mp_enable_stats.*/StatsD_Checker.mp_enable_stats := false;/" $VOL_BASE_DIR/pcu-tester/PCU_Tests.cfg
	sed -i "s/stats interval 0//" $VOL_BASE_DIR/pcu/osmo-pcu.cfg
	sed -i "s/flush-period 1//" $VOL_BASE_DIR/pcu/osmo-pcu.cfg

	# neighbor resolution only available in osmo-pcu > 0.8.0
	sed "/neighbor resolution/d" -i $VOL_BASE_DIR/pcu/osmo-pcu.cfg
fi

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
		$REPO_USER/ttcn3-pcu-test "$@"

echo Stopping containers
docker container kill ${BUILD_TAG}-pcu

network_remove
rm -rf $VOL_BASE_DIR/unix
collect_logs
