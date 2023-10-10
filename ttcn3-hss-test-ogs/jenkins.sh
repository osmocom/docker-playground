#!/bin/sh

. ../jenkins-common.sh

IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"open5gs-$IMAGE_SUFFIX" \
	"ttcn3-hss-test-ogs"

set_clean_up_trap
set -e

mkdir -p $VOL_BASE_DIR/mongo/db
cp ogs/mongod.conf $VOL_BASE_DIR/mongo/

mkdir $VOL_BASE_DIR/hss-tester
cp ogs/HSS_Tests.cfg $VOL_BASE_DIR/hss-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/hss-tester/HSS_Tests.cfg"

mkdir $VOL_BASE_DIR/hss
cp ogs/open5gs-*.yaml $VOL_BASE_DIR/hss/
cp ogs/freediameter.conf $VOL_BASE_DIR/hss/

network_create
network_replace_subnet_in_configs

# start container with mongod in background
docker run	--rm --user $(id -u) \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/mongo:/data \
		--name ${BUILD_TAG}-mongo -d \
		$DOCKER_ARGS \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		/bin/sh -c "mongod -f /data/mongod.conf >/data/mongod.out 2>&1"

# mongod needs some time to bootstrap...
while ! nc -z 172.18.$SUBNET.103 27017; do sleep 1; done

# create a test subscriber with IMSI=001010000000000
docker run	--rm \
		$(docker_network_params $SUBNET 8) \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		open5gs-dbctl --db_uri=mongodb://172.18.$SUBNET.103/open5gs \
			add 001010000000000 \
				3c6e0b8a9c15224a8228b9a98ca1531d \
				762a2206fe0b4151ace403c86a11e479

# start container with hss in background
docker run	--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/hss:/data \
		--name ${BUILD_TAG}-ogs-hss -d \
		$DOCKER_ARGS \
		$(docker_network_params $SUBNET 201) \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		/bin/sh -c "open5gs-hssd -c /data/open5gs-hss.yaml >/data/open5gs-hssd.out 2>&1"

# start docker container with testsuite in foreground
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		$(docker_network_params $SUBNET 202) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/hss-tester:/data \
		-e "TTCN3_PCAP_PATH=/data" \
		--name ${BUILD_TAG}-hss-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-hss-test-ogs

# remove mongodb's database
rm -rf $VOL_BASE_DIR/mongo/db/
