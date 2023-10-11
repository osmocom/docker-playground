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

MONGOD_ADDR="172.18.$SUBNET.103"
DBCTL="open5gs-dbctl --db_uri=mongodb://$MONGOD_ADDR/open5gs"

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
while ! nc -z $MONGOD_ADDR 27017; do sleep 1; done

# create a test subscriber with IMSI=001010000000000
docker run	--rm \
		$(docker_network_params $SUBNET 8) \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		$DBCTL add 001010000000000 3c6e0b8a9c15224a8228b9a98ca1531d 762a2206fe0b4151ace403c86a11e479

# Mark test subscriber with IMSI=001010000000001 as:
# Subscriber-Status=OPERATOR_DETERMINED_BARRING (1)
# Operator-Determined-Barring="Barring of all outgoing inter-zonal calls except those directed to the home PLMN country" (7)
docker run	--rm \
		$(docker_network_params $SUBNET 8) \
		$REPO_USER/open5gs-$IMAGE_SUFFIX \
		/bin/sh -c "$DBCTL add 001010000000001 3c6e0b8a9c15224a8228b9a98ca1531d 762a2206fe0b4151ace403c86a11e479 &&
			    $DBCTL subscriber_status 001010000000001 1 7"

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
