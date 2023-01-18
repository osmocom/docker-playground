#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
# NOTE: there is no osmocom-bb-host-latest, hence always use master!
docker_images_require \
	"osmo-bsc-$IMAGE_SUFFIX" \
	"osmo-bts-$IMAGE_SUFFIX" \
	"osmocom-bb-host-master" \
	"ttcn3-bts-test"

set_clean_up_trap
set -e

clean_up() {
	# append ':hopping' to the classnames,
	# e.g. "classname='BTS_Tests'" => "classname='BTS_Tests:hopping'"
	# e.g. "classname='BTS_Tests_SMSCB'" => "classname='BTS_Tests_SMSCB:hopping'"
	# so the hopping test cases would not interfere with non-hopping ones in Jenkins
	sed -i "s/classname='\([^']\+\)'/classname='\1:hopping'/g" \
		$VOL_BASE_DIR/bts-tester-hopping/junit-xml-hopping-*.log
}

start_bsc() {
	echo Starting container with BSC
	docker run	--rm \
			$(docker_network_params $SUBNET 11) \
			--ulimit core=-1 \
			-v $VOL_BASE_DIR/bsc:/data \
			--name ${BUILD_TAG}-bsc -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-bsc-$IMAGE_SUFFIX \
			/bin/sh -c "osmo-bsc -c /data/osmo-bsc.gen.cfg >>/data/osmo-bsc.log 2>&1"
}

start_bts() {
	local variant
	variant="$1"
	sleep_time_respawn="$2"
	echo Starting container with BTS
	if [ -z "$variant" ]; then
		echo ERROR: You have to specify a BTS variant
		exit 23
	fi
	docker run	--rm \
			$(docker_network_params $SUBNET 20) \
			--ulimit core=-1 \
			-v $VOL_BASE_DIR/bts:/data \
			-v $VOL_BASE_DIR/unix:/data/unix \
			-e "SLEEP_BEFORE_RESPAWN=$sleep_time_respawn" \
			--name ${BUILD_TAG}-bts -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-bts-$IMAGE_SUFFIX \
			/bin/sh -c "/usr/local/bin/respawn.sh osmo-bts-$variant -c /data/osmo-bts.gen.cfg >>/data/osmo-bts.log 2>&1"
}

start_fake_trx() {
	echo Starting container with fake_trx
	docker run	--rm \
			$(docker_network_params $SUBNET 21) \
			--ulimit core=-1 \
			-v $VOL_BASE_DIR/fake_trx:/data \
			--name ${BUILD_TAG}-fake_trx -d \
			$DOCKER_ARGS \
			$REPO_USER/osmocom-bb-host-master \
			/bin/sh -c "/tmp/osmocom-bb/src/target/trx_toolkit/fake_trx.py \
				--log-file-name /data/fake_trx.log \
				--log-file-level DEBUG \
				--log-file-time \
				--log-level INFO \
				-R 172.18.$SUBNET.20 \
				-r 172.18.$SUBNET.22 \
				--trx TRX1@172.18.$SUBNET.20:5700/1 \
				--trx TRX2@172.18.$SUBNET.20:5700/2 \
				--trx TRX3@172.18.$SUBNET.20:5700/3 \
				>>/data/fake_trx.out 2>&1"
}

start_trxcon() {
	echo Starting container with trxcon
	docker run	--rm \
			$(docker_network_params $SUBNET 22) \
			--ulimit core=-1 \
			-v $VOL_BASE_DIR/trxcon:/data \
			-v $VOL_BASE_DIR/unix:/data/unix \
			--name ${BUILD_TAG}-trxcon -d \
			$DOCKER_ARGS \
			$REPO_USER/osmocom-bb-host-master \
			/bin/sh -c "trxcon \
				-i 172.18.$SUBNET.21 \
				-s /data/unix/osmocom_l2 \
				>>/data/trxcon.log 2>&1"
}

start_virtphy() {
	echo Starting container with virtphy
	docker run	--rm \
			$(docker_network_params $SUBNET 22) \
			--ulimit core=-1 \
			-v $VOL_BASE_DIR/virtphy:/data \
			-v $VOL_BASE_DIR/unix:/data/unix \
			--name ${BUILD_TAG}-virtphy -d \
			$DOCKER_ARGS \
			$REPO_USER/osmocom-bb-host-master \
			/bin/sh -c "virtphy -s /data/unix/osmocom_l2 >>/data/virtphy.log 2>&1"
}

start_testsuite() {
	echo Starting container with BTS testsuite
	variant=$1 # e.g 'generic', 'oml', 'hopping'
	docker run	--rm \
			$(docker_network_params $SUBNET 10) \
			--ulimit core=-1 \
			-e "TTCN3_PCAP_PATH=/data" \
			-e "OSMO_SUT_HOST=172.18.$SUBNET.20" \
			-e "OSMO_SUT_PORT=4241" \
			-v $VOL_BASE_DIR/bts-tester-${variant}:/data \
			-v $VOL_BASE_DIR/unix:/data/unix \
			--name ${BUILD_TAG}-ttcn3-bts-test \
			$DOCKER_ARGS \
			$REPO_USER/ttcn3-bts-test
}

network_create

mkdir $VOL_BASE_DIR/bts-tester-generic
cp generic/BTS_Tests.cfg $VOL_BASE_DIR/bts-tester-generic/
write_mp_osmo_repo "$VOL_BASE_DIR/bts-tester-generic/BTS_Tests.cfg"
mkdir $VOL_BASE_DIR/bts-tester-virtphy
cp virtphy/BTS_Tests.cfg $VOL_BASE_DIR/bts-tester-virtphy/
write_mp_osmo_repo "$VOL_BASE_DIR/bts-tester-virtphy/BTS_Tests.cfg"
mkdir $VOL_BASE_DIR/bts-tester-oml
cp oml/BTS_Tests.cfg $VOL_BASE_DIR/bts-tester-oml/
write_mp_osmo_repo "$VOL_BASE_DIR/bts-tester-oml/BTS_Tests.cfg"
mkdir $VOL_BASE_DIR/bts-tester-hopping
cp fh/BTS_Tests.cfg $VOL_BASE_DIR/bts-tester-hopping/
write_mp_osmo_repo "$VOL_BASE_DIR/bts-tester-hopping/BTS_Tests.cfg"

cp $VOL_BASE_DIR/bts-tester-generic/BTS_Tests.cfg \
   $VOL_BASE_DIR/bts-tester-hopping/BTS_Tests.cfg.inc

# (re)generate the configuration files
cp Makefile $VOL_BASE_DIR/Makefile
network_replace_subnet_in_configs
make -f $VOL_BASE_DIR/Makefile cfg

mkdir $VOL_BASE_DIR/bsc
cp generic/osmo-bsc.gen.cfg $VOL_BASE_DIR/bsc/

mkdir $VOL_BASE_DIR/bts
mkdir $VOL_BASE_DIR/bts/unix
cp generic/osmo-bts.gen.cfg $VOL_BASE_DIR/bts/
# Disable until osmo-bts release > 1.5.0
if ! image_suffix_is_master; then
	sed -i "/^ logging level osmux info/d" $VOL_BASE_DIR/bts/osmo-bts.gen.cfg
	sed -i "/^ osmux/{N;N;N;N;d;}" $VOL_BASE_DIR/bts/osmo-bts.gen.cfg
fi

mkdir $VOL_BASE_DIR/unix

mkdir $VOL_BASE_DIR/fake_trx
mkdir $VOL_BASE_DIR/trxcon
mkdir $VOL_BASE_DIR/virtphy

# 1) classic test suite with BSC for OML and trxcon+fake_trx
network_replace_subnet_in_configs
start_bsc
start_bts trx 1
start_fake_trx
start_trxcon
start_testsuite generic

# 2) some GPRS tests require virt_phy
echo "Changing to virtphy configuration"
# switch from osmo-bts-trx + trxcon + faketrx to virtphy + osmo-bts-virtual
docker container kill ${BUILD_TAG}-trxcon
docker container kill ${BUILD_TAG}-fake_trx
docker container kill ${BUILD_TAG}-bts
cp virtphy/osmo-bts.gen.cfg $VOL_BASE_DIR/bts/
# Disable until osmo-bts release > 1.5.0
if ! image_suffix_is_master; then
	sed -i "/^ logging level osmux info/d" $VOL_BASE_DIR/bts/osmo-bts.gen.cfg
	sed -i "/^ osmux/{N;N;N;N;d;}" $VOL_BASE_DIR/bts/osmo-bts.gen.cfg
fi
network_replace_subnet_in_configs
start_bts virtual 0
start_virtphy
# ... and execute the testsuite again with different cfg
#start_testsuite virtphy

# 3) OML tests require us to run without BSC
docker container kill ${BUILD_TAG}-bsc
# switch back from virtphy + osmo-bts-virtual to osmo-bts-trx
docker container kill ${BUILD_TAG}-virtphy
docker container kill ${BUILD_TAG}-bts

cp oml/osmo-bts.gen.cfg $VOL_BASE_DIR/bts/
# Disable until osmo-bts release > 1.5.0
if ! image_suffix_is_master; then
	sed -i "/^ logging level osmux info/d" $VOL_BASE_DIR/bts/osmo-bts.gen.cfg
	sed -i "/^ osmux/{N;N;N;N;d;}" $VOL_BASE_DIR/bts/osmo-bts.gen.cfg
fi
network_replace_subnet_in_configs
start_bts trx 1
start_fake_trx
start_trxcon
# ... and execute the testsuite again with different cfg
start_testsuite oml

# 4) Frequency hopping tests require different configuration files
cp fh/osmo-bsc.gen.cfg $VOL_BASE_DIR/bsc/
cp generic/osmo-bts.gen.cfg $VOL_BASE_DIR/bts/
# Disable until osmo-bts release > 1.5.0
if ! image_suffix_is_master; then
	sed -i "/^ logging level osmux info/d" $VOL_BASE_DIR/bts/osmo-bts.gen.cfg
	sed -i "/^ osmux/{N;N;N;N;d;}" $VOL_BASE_DIR/bts/osmo-bts.gen.cfg
fi
# restart the BSC/BTS and run the testsuite again
docker container kill ${BUILD_TAG}-bts
network_replace_subnet_in_configs
start_bsc
start_bts trx 1
start_testsuite hopping
