#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
# NOTE: there is no osmocom-bb-host-latest, hence always use master!
docker_images_require \
	"debian-jessie-build" \
	"osmo-bsc-$IMAGE_SUFFIX" \
	"osmo-bts-$IMAGE_SUFFIX" \
	"osmocom-bb-host-master" \
	"debian-stretch-titan" \
	"ttcn3-bts-test"

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

echo Starting container with BSC
docker run	--rm \
		--network $NET_NAME --ip 172.18.9.11 \
		-v $VOL_BASE_DIR/bsc:/data \
		--name ${BUILD_TAG}-bsc -d \
		$REPO_USER/osmo-bsc-$IMAGE_SUFFIX \
		osmo-bsc -c /data/osmo-bsc.cfg

echo Starting container with BTS
docker run	--rm \
		--network $NET_NAME --ip 172.18.9.20 \
		-v $VOL_BASE_DIR/bts:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-bts -d \
		$REPO_USER/osmo-bts-$IMAGE_SUFFIX \
		/usr/local/bin/respawn.sh osmo-bts-trx -c /data/osmo-bts.cfg -i 172.18.9.10

echo Starting container with fake_trx
docker run	--rm \
		--network $NET_NAME --ip 172.18.9.21 \
		-v $VOL_BASE_DIR/fake_trx:/data \
		--name ${BUILD_TAG}-fake_trx -d \
		$REPO_USER/osmocom-bb-host-master \
		/tmp/osmocom-bb/src/target/trx_toolkit/fake_trx.py \
			--log-file-name /data/fake_trx.log \
			--log-file-level DEBUG \
			--log-level INFO \
			-R 172.18.9.20 -r 172.18.9.22

echo Starting container with trxcon
docker run	--rm \
		--network $NET_NAME --ip 172.18.9.22 \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-trxcon -d \
		$REPO_USER/osmocom-bb-host-master \
		trxcon -i 172.18.9.21 -s /data/unix/osmocom_l2


echo Starting container with BTS testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.9.10 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/bts-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-ttcn3-bts-test \
		$REPO_USER/ttcn3-bts-test

echo Stopping containers
docker container kill ${BUILD_TAG}-trxcon
docker container kill ${BUILD_TAG}-fake_trx
docker container kill ${BUILD_TAG}-bts
docker container kill ${BUILD_TAG}-bsc

network_remove
rm -rf $VOL_BASE_DIR/unix
collect_logs
