#!/bin/sh

. ../jenkins-common.sh

KERNEL_TEST="${KERNEL_TEST:-0}"
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"open5gs-$IMAGE_SUFFIX" \
	"ttcn3-ggsn-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/ggsn-tester
cp ogs/GGSN_Tests.cfg $VOL_BASE_DIR/ggsn-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/ggsn-tester/GGSN_Tests.cfg"

mkdir $VOL_BASE_DIR/ggsn
cp ogs/open5gs-*.yaml $VOL_BASE_DIR/ggsn/
cp ogs/freediameter.conf $VOL_BASE_DIR/ggsn/
cp ogs/upfd.sh $VOL_BASE_DIR/ggsn/
cp ogs/upfd-setup.sh $VOL_BASE_DIR/ggsn/

network_create
network_replace_subnet_in_configs

# start container with ggsn (smf+upf) in background
docker run	--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/ggsn:/data \
		--name ${BUILD_TAG}-ggsn-ogs-smf -d \
		$DOCKER_ARGS \
		$(docker_network_params $SUBNET 201) \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		/bin/sh -c "open5gs-smfd -c /data/open5gs-smf.yaml >/data/open5gs-smfd.out 2>&1"
		#/bin/sh -c "gdb -ex 'handle SIG32 pass nostop noprint' -ex 'run' -ex 'bt' --arg open5gs-smfd -c /data/open5gs-smf.yaml >/data/open5gs-smfd.out 2>&1"
		#/bin/sh -c "valgrind --tool=memcheck --leak-check=yes --show-reachable=yes --num-callers=20 --track-fds=yes open5gs-smfd -c /data/open5gs-smf.yaml >/data/open5gs-smfd.out 2>&1"

docker run	--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/ggsn:/data \
		--name ${BUILD_TAG}-ggsn-ogs-upf -d \
		$DOCKER_ARGS \
		$(docker_network_params $SUBNET 222) \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		/bin/sh -c "/data/upfd.sh -c /data/open5gs-upf.yaml >/data/open5gs-upfd.out 2>&1"

# start docker container with testsuite in foreground
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		$(docker_network_params $SUBNET 202) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/ggsn-tester:/data \
		-e "TTCN3_PCAP_PATH=/data" \
		--name ${BUILD_TAG}-ggsn-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-ggsn-test
