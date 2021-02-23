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
	"osmo-gbproxy-$IMAGE_SUFFIX" \
	"ttcn3-gbproxy-test"

SUBNET=25
network_create $SUBNET

mkdir $VOL_BASE_DIR/gbproxy-tester
# if we don't change permissions, dumpcap fails to write (despite starting it as root!)
chmod a+w $VOL_BASE_DIR/gbproxy-tester
cp GBProxy_Tests.cfg $VOL_BASE_DIR/gbproxy-tester/

mkdir $VOL_BASE_DIR/gbproxy
cp osmo-gbproxy.cfg $VOL_BASE_DIR/gbproxy/

mkdir $VOL_BASE_DIR/unix

echo Starting container with gbproxy
docker run	--rm \
		--cap-add=NET_RAW --cap-add=SYS_RAWIO \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-e "WAIT_FOR_NETDEV=hdlcnet8" \
		-v $VOL_BASE_DIR/gbproxy:/data \
		--name ${BUILD_TAG}-gbproxy -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-gbproxy-$IMAGE_SUFFIX

# move all hdlcnetX net-devices into container
for i in `seq 1 8`; do
	DEV="hdlcnet$i"
	#sudo sethdlc ${DEV} fr lmi none
	sudo ./netdev-to-docker.sh ${DEV} ${BUILD_TAG}-gbproxy
done

echo Starting container with gbproxy testsuite
docker run	--rm \
		--cap-add=NET_RAW --cap-add=SYS_RAWIO \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "WAIT_FOR_NETDEV=hdlc8" \
		-v $VOL_BASE_DIR/gbproxy-tester:/data \
		--name ${BUILD_TAG}-ttcn3-gbproxy-test -d \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-gbproxy-test $@

# move all hdlcnetX net-devices into container
for i in `seq 1 8`; do
	DEV="hdlc$i"
	#sudo sethdlc ${DEV} fr lmi none
	sudo ./netdev-to-docker.sh ${DEV} ${BUILD_TAG}-ttcn3-gbproxy-test
done

# emulate runnign container in foreground, which is no longer possible as we
# must shift the net-devices into the container _after_ it is started
docker logs	-f ${BUILD_TAG}-ttcn3-gbproxy-test

echo Stopping containers
docker container kill ${BUILD_TAG}-gbproxy

network_remove
collect_logs
