#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
# NOTE: there is no osmocom-bb-host-latest, hence always use master!
docker_images_require \
	"debian-stretch-build" \
	"osmo-bsc-$IMAGE_SUFFIX" \
	"osmo-bts-$IMAGE_SUFFIX" \
	"osmocom-bb-host-master" \
	"debian-stretch-titan" \
	"ttcn3-bts-test"

start_bsc() {
	echo Starting container with BSC
	docker run	--rm \
			--network $NET_NAME --ip 172.18.9.11 \
			-v $VOL_BASE_DIR/bsc:/data \
			--name ${BUILD_TAG}-bsc -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-bsc-$IMAGE_SUFFIX \
			/bin/sh -c "osmo-bsc -c /data/osmo-bsc.cfg >>/data/osmo-bsc.log 2>&1"
}

start_bts() {
	local variant
	variant="$1"
	echo Starting container with BTS
	if [ -z "$variant" ]; then
		echo ERROR: You have to specify a BTS variant
		exit 23
	fi
	docker run	--rm \
			--network $NET_NAME --ip 172.18.9.20 \
			-v $VOL_BASE_DIR/bts:/data \
			-v $VOL_BASE_DIR/unix:/data/unix \
			--name ${BUILD_TAG}-bts -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-bts-$IMAGE_SUFFIX \
			/bin/sh -c "/usr/local/bin/respawn.sh osmo-bts-$variant -c /data/osmo-bts.cfg -i 172.18.9.10 >>/data/osmo-bts.log 2>&1"
}

start_fake_trx() {
	echo Starting container with fake_trx
	docker run	--rm \
			--network $NET_NAME --ip 172.18.9.21 \
			-v $VOL_BASE_DIR/fake_trx:/data \
			--name ${BUILD_TAG}-fake_trx -d \
			$DOCKER_ARGS \
			$REPO_USER/osmocom-bb-host-master \
			/tmp/osmocom-bb/src/target/trx_toolkit/fake_trx.py \
				--log-file-name /data/fake_trx.log \
				--log-file-level DEBUG \
				--log-file-time \
				--log-level INFO \
				-R 172.18.9.20 -r 172.18.9.22 \
				--trx TRX1@172.18.9.20:5700/1 \
				--trx TRX2@172.18.9.20:5700/2 \
				--trx TRX3@172.18.9.20:5700/3
}

start_trxcon() {
	echo Starting container with trxcon
	docker run	--rm \
			--network $NET_NAME --ip 172.18.9.22 \
			-v $VOL_BASE_DIR/trxcon:/data \
			-v $VOL_BASE_DIR/unix:/data/unix \
			--name ${BUILD_TAG}-trxcon -d \
			$DOCKER_ARGS \
			$REPO_USER/osmocom-bb-host-master \
			/bin/sh -c "trxcon -i 172.18.9.21 -s /data/unix/osmocom_l2 >>/data/trxcon.log 2>&1"
}

start_virtphy() {
	echo Starting container with virtphy
	docker run	--rm \
			--network $NET_NAME --ip 172.18.9.22 \
			-v $VOL_BASE_DIR/unix:/data/unix \
			--name ${BUILD_TAG}-virtphy -d \
			$DOCKER_ARGS \
			$REPO_USER/osmocom-bb-host-master \
			virtphy -s /data/unix/osmocom_l2
			/bin/sh -c "virtphy -s /data/unix/osmocom_l2 >>/data/virtphy.log 2>&1"
}

start_testsuite() {
	echo Starting container with BTS testsuite
	docker run	--rm \
			--network $NET_NAME --ip 172.18.9.10 \
			-e "TTCN3_PCAP_PATH=/data" \
			-v $VOL_BASE_DIR/bts-tester:/data \
			-v $VOL_BASE_DIR/unix:/data/unix \
			--name ${BUILD_TAG}-ttcn3-bts-test \
			$DOCKER_ARGS \
			$REPO_USER/ttcn3-bts-test
}

network_create 172.18.9.0/24

mkdir $VOL_BASE_DIR/bts-tester
mkdir $VOL_BASE_DIR/bts-tester/unix
cp BTS_Tests.cfg $VOL_BASE_DIR/bts-tester/

mkdir $VOL_BASE_DIR/bsc
cp osmo-bsc.cfg $VOL_BASE_DIR/bsc/

mkdir $VOL_BASE_DIR/bts
mkdir $VOL_BASE_DIR/bts/unix
cp osmo-bts.cfg $VOL_BASE_DIR/bts/

mkdir $VOL_BASE_DIR/unix

mkdir $VOL_BASE_DIR/fake_trx
mkdir $VOL_BASE_DIR/trxcon

# 1) classic test suite with BSC for OML and trxcon+fake_trx
start_bsc
start_bts trx
start_fake_trx
start_trxcon
start_testsuite

# 2) some GPRS tests require virt_phy
echo "Changing to virtphy configuration"
# switch from osmo-bts-trx + trxcon + faketrx to virtphy + osmo-bts-virtual
docker container kill ${BUILD_TAG}-trxcon
docker container kill ${BUILD_TAG}-fake_trx
docker container kill ${BUILD_TAG}-bts
cp virtphy/osmo-bts.cfg $VOL_BASE_DIR/bts/
start_bts virtual
start_virtphy
# ... and execute the testsuite again with different cfg
cp virtphy/BTS_Tests.cfg $VOL_BASE_DIR/bts-tester/
#start_testsuite

# 3) OML tests require us to run without BSC
docker container kill ${BUILD_TAG}-bsc
# switch back from virtphy + osmo-bts-virtual to osmo-bts-trx
docker container kill ${BUILD_TAG}-virtphy
docker container kill ${BUILD_TAG}-bts
cp oml/osmo-bts.cfg $VOL_BASE_DIR/bts/
start_bts trx
start_fake_trx
start_trxcon
# ... and execute the testsuite again with different cfg
cp oml/BTS_Tests.cfg $VOL_BASE_DIR/bts-tester/
start_testsuite

echo Stopping containers
docker container kill ${BUILD_TAG}-trxcon
docker container kill ${BUILD_TAG}-fake_trx
docker container kill ${BUILD_TAG}-bts


network_remove
rm -rf $VOL_BASE_DIR/unix
collect_logs
