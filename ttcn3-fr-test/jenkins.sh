#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"ttcn3-fr-test"

set_clean_up_trap
set -e

clean_up() {
	# kill the frnet container to avoid "You cannot remove a running container " below in 'rm'
	docker_kill_wait ${BUILD_TAG}-frnet || true

	# store execution logs for both containers
	docker logs --timestamps ${BUILD_TAG}-ttcn3-fr-test > $VOL_BASE_DIR/fr-tester/exec.log || true
	docker logs --timestamps ${BUILD_TAG}-frnet > $VOL_BASE_DIR/frnet/exec.log || true
	docker container rm ${BUILD_TAG}-frnet ${BUILD_TAG}-ttcn3-fr-test
}

mkdir $VOL_BASE_DIR/fr-tester
# if we don't change permissions, dumpcap fails to write (despite starting it as root!)
chmod a+w $VOL_BASE_DIR/fr-tester

cp FR_Tests.cfg $VOL_BASE_DIR/fr-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/fr-tester/FR_Tests.cfg"

mkdir $VOL_BASE_DIR/frnet
cp FRNET_Tests.cfg $VOL_BASE_DIR/frnet/

mkdir $VOL_BASE_DIR/unix

network_clean_remove_all_ttcn3
network_create
network_replace_subnet_in_configs

echo Starting container with FRNET
docker run	\
		`# --rm is done in clean_up()` \
		--cap-add=NET_RAW --cap-add=SYS_RAWIO \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "WAIT_FOR_NETDEV=hdlcnet8" \
		-v $VOL_BASE_DIR/frnet:/data \
		--name ${BUILD_TAG}-frnet -d \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-fr-test fr-net FRNET_Tests

# move all hdlcnetX net-devices into container
for i in `seq 1 8`; do
	DEV="hdlcnet$i"
	#sudo sethdlc ${DEV} fr lmi none
	sudo ./netdev-to-docker.sh ${DEV} ${BUILD_TAG}-frnet
done

echo Starting container with FR testsuite
docker run	\
		`# --rm is done in clean_up()` \
		--cap-add=NET_RAW --cap-add=SYS_RAWIO \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "WAIT_FOR_NETDEV=hdlc8" \
		-v $VOL_BASE_DIR/fr-tester:/data \
		--name ${BUILD_TAG}-ttcn3-fr-test -d \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-fr-test fr FR_Tests

# move all hdlcnetX net-devices into container
for i in `seq 1 8`; do
	DEV="hdlc$i"
	#sudo sethdlc ${DEV} fr lmi none
	sudo ./netdev-to-docker.sh ${DEV} ${BUILD_TAG}-ttcn3-fr-test
done

# emulate running container in foreground, which is no longer possible as we
# must shift the net-devices into the container _after_ it is started
docker logs	-f ${BUILD_TAG}-ttcn3-fr-test
