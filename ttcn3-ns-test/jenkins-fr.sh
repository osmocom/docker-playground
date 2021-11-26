#!/bin/sh

# WARNING: This cannot be executed on any random Linux machine or jenkins slave node!
#
# We require a kernel with HLDC net-devices, specifically eight pairs of devices named
# hdlc1 + hdlcnet1 ... hdlc8 + hdclnet8.
#
# Those pairs of netdevices can e.g. be implemented by actually physically looping back
# the related E1 interfaces, or e.g.by using DAHDI_NET + dahdi_dynamic_loc to create
# pairs of virtual E1 spans.
#
# In addition, we need to use 'sudo' permissions in order to move the hdlc
# net-devices into the docker containers. So in automatic test execution this means
# that the user will need sudo privileges without entering a password (NOPASS)

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-ns-$IMAGE_SUFFIX" \
	"ttcn3-ns-test"

set_clean_up_trap
set -e

SUBNET=30
network_create $SUBNET

mkdir $VOL_BASE_DIR/ns-tester
cp fr/NS_Tests.cfg $VOL_BASE_DIR/ns-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/ns-tester/NS_Tests.cfg"

mkdir $VOL_BASE_DIR/ns
cp fr/osmo-ns-dummy.cfg $VOL_BASE_DIR/ns/

echo Starting container with osmo-ns-dummy
docker run	--rm \
		--cap-add=NET_RAW --cap-add=SYS_RAWIO \
		$(docker_network_params $SUBNET 101) \
		--ulimit core=-1 \
		-e "WAIT_FOR_NETDEV=hdlcnet8" \
		-v $VOL_BASE_DIR/ns:/data \
		--name ${BUILD_TAG}-ns -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-ns-$IMAGE_SUFFIX

# move all hdlcX net-devices into container
for i in `seq 1 8`; do
	DEV="hdlcnet$i"
	#sudo sethdlc ${DEV} fr lmi none
	sudo ./netdev-to-docker.sh ${DEV} ${BUILD_TAG}-ns
done

echo Starting container with NS testsuite
docker run	--rm \
		--cap-add=NET_RAW --cap-add=SYS_RAWIO \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "WAIT_FOR_NETDEV=hdlc8" \
		-v $VOL_BASE_DIR/ns-tester:/data \
		--name ${BUILD_TAG}-ttcn3-ns-test -d \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-ns-test

# move all hdlcnetX net-devices into container
for i in `seq 1 8`; do
	DEV="hdlc$i"
	#sudo sethdlc ${DEV} fr lmi none
	sudo ./netdev-to-docker.sh ${DEV} ${BUILD_TAG}-ttcn3-ns-test
done

# emulate running container in foreground, which is no longer possible as we
# must shift the net-devices into the container _after_ it is started
docker logs	-f ${BUILD_TAG}-ttcn3-ns-test
