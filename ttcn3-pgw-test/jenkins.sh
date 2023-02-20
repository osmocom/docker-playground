#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"open5gs-$IMAGE_SUFFIX" \
	"osmo-uecups-$IMAGE_SUFFIX" \
	"ttcn3-pgw-test"

mkdir $VOL_BASE_DIR/pgw-tester
cp PGW_Tests.cfg $VOL_BASE_DIR/pgw-tester/

mkdir $VOL_BASE_DIR/osmo-uecups
cp osmo-uecups-daemon.cfg $VOL_BASE_DIR/osmo-uecups/

mkdir $VOL_BASE_DIR/pgw
cp freeDiameter-smf.conf $VOL_BASE_DIR/pgw/
cp open5gs-*.yaml $VOL_BASE_DIR/pgw/
cp upfd.sh $VOL_BASE_DIR/pgw/
cp upfd-setup.sh $VOL_BASE_DIR/pgw/

network_create
network_replace_subnet_in_configs

# start container with open5gs-nrfd in background
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/pgw:/data \
		--name ${BUILD_TAG}-nrf -d \
		$DOCKER_ARGS \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		/bin/sh -c "open5gs-nrfd -c /data/open5gs-nrf.yaml >/data/open5gs-nrf.out 2>&1"

# start container with open5gs-upfd in background
docker run	--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		$(docker_network_params $SUBNET 7) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/pgw:/data \
		--name ${BUILD_TAG}-upf -d \
		$DOCKER_ARGS \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		/bin/sh -c "/data/upfd.sh -c /data/open5gs-upf.yaml >/data/open5gs-upfd.out 2>&1"

# start container with open5gs-smfd in background
docker run	--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		$(docker_network_params $SUBNET 4) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/pgw:/data \
		--name ${BUILD_TAG}-smf -d \
		$DOCKER_ARGS \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		/bin/sh -c "open5gs-smfd -c /data/open5gs-smf.yaml >/data/open5gs-smfd.out 2>&1"
		#/bin/sh -c "gdb -ex 'handle SIG32 pass nostop noprint' -ex 'run' -ex 'bt' --arg open5gs-smfd -c /data/open5gs-smf.yaml >/data/open5gs-smfd.out 2>&1"

# start container with osmo-ugcups-daemon in background; SYS_ADMIN required for CLONE_NEWNS
docker run	--cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/osmo-uecups:/data \
		-e "WORKDIR=/data" \
		--name ${BUILD_TAG}-uecups -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-uecups-$IMAGE_SUFFIX \
		/bin/sh -c "osmo-uecups-daemon -c /data/osmo-uecups-daemon.cfg >/data/osmo-uecups-daemon.log 2>&1"

# start docker container with testsuite in foreground
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		$(docker_network_params $SUBNET 202) \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/pgw-tester:/data \
		--name ${BUILD_TAG}-pgw-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-pgw-test

# stop uecups + PGW after test has completed
docker container stop \
	${BUILD_TAG}-uecups \
	${BUILD_TAG}-smf \
	${BUILD_TAG}-upf \
	${BUILD_TAG}-nrf

network_remove
collect_logs
