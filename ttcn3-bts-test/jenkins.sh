#!/bin/sh
TEST_CONFIGS_ALL="generic virtphy oml hopping"
TEST_CONFIGS="${TEST_CONFIGS:-"generic oml hopping"}"

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
	if test_config_enabled "hopping"; then
		# append ':hopping' to the classnames,
		# e.g. "classname='BTS_Tests'" => "classname='BTS_Tests:hopping'"
		# e.g. "classname='BTS_Tests_SMSCB'" => "classname='BTS_Tests_SMSCB:hopping'"
		# so the hopping test cases would not interfere with non-hopping ones in Jenkins
		sed -i "s/classname='\([^']\+\)'/classname='\1:hopping'/g" \
			$VOL_BASE_DIR/bts-tester-hopping/junit-xml-hopping-*.log
	fi
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
			--name ${BUILD_TAG}-bts -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-bts-$IMAGE_SUFFIX \
			/bin/sh -c "osmo-bts-$variant -c /data/osmo-bts.gen.cfg >>/data/osmo-bts.log 2>&1"
}

start_fake_trx() {
	echo Starting container with fake_trx
	docker run	--rm \
			$(docker_network_params $SUBNET 21) \
			--cap-add=SYS_ADMIN \
			--ulimit rtprio=99 \
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
				--sched-rr-prio 30 \
				-R $SUB4_PREFIX.$SUBNET.20 \
				-r $SUB4_PREFIX.$SUBNET.22 \
				--trx TRX1@$SUB4_PREFIX.$SUBNET.20:5700/1 \
				--trx TRX2@$SUB4_PREFIX.$SUBNET.20:5700/2 \
				--trx TRX3@$SUB4_PREFIX.$SUBNET.20:5700/3 \
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
				-i $SUB4_PREFIX.$SUBNET.21 \
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
			-e "OSMO_SUT_HOST=$SUB4_PREFIX.$SUBNET.20" \
			-e "OSMO_SUT_PORT=4241" \
			-v $VOL_BASE_DIR/bts-tester-${variant}:/data \
			-v $VOL_BASE_DIR/unix:/data/unix \
			--name ${BUILD_TAG}-ttcn3-bts-test \
			$DOCKER_ARGS \
			$REPO_USER/ttcn3-bts-test
}

set_pcuif_version() {
	if osmo_repo_is_2023q1; then
		sed -i 's/PCUIF_Types.mp_pcuif_version := 12/PCUIF_Types.mp_pcuif_version := 10/g' $1
	fi
}

# Classic test suite with BSC for OML and trxcon+fake_trx
start_config_generic() {
	if ! test_config_enabled "generic"; then
		return
	fi

	network_replace_subnet_in_configs

	start_bsc
	start_bts trx 1
	start_fake_trx
	start_trxcon

	start_testsuite generic

	docker_kill_wait ${BUILD_TAG}-trxcon
	docker_kill_wait ${BUILD_TAG}-fake_trx
	docker_kill_wait ${BUILD_TAG}-bts
	docker_kill_wait ${BUILD_TAG}-bsc
}

# Some GPRS tests require virt_phy
start_config_virtphy() {
	if ! test_config_enabled "virtphy"; then
		return
	fi

	# FIXME: multicast to/from a docker bridge network is currently not possible.
	# See https://github.com/moby/libnetwork/issues/2397.
	set +x
	echo "ERROR: not running the virtphy configuration"
	exit 1

	cp virtphy/osmo-bts.gen.cfg $VOL_BASE_DIR/bts/
	network_replace_subnet_in_configs

	start_bsc
	start_bts virtual 0
	start_virtphy

	start_testsuite virtphy

	docker_kill_wait ${BUILD_TAG}-virtphy
	docker_kill_wait ${BUILD_TAG}-bts
	docker_kill_wait ${BUILD_TAG}-bsc
}

# OML tests require us to run without BSC
start_config_oml() {
	if ! test_config_enabled "oml"; then
		return
	fi

	cp oml/osmo-bts.gen.cfg $VOL_BASE_DIR/bts/
	network_replace_subnet_in_configs

	start_bts trx 1
	start_fake_trx
	start_trxcon

	start_testsuite oml

	docker_kill_wait ${BUILD_TAG}-trxcon
	docker_kill_wait ${BUILD_TAG}-fake_trx
	docker_kill_wait ${BUILD_TAG}-bts
}

# Frequency hopping tests require different configuration files
start_config_hopping() {
	if ! test_config_enabled "hopping"; then
		return
	fi

	cp fh/osmo-bsc.gen.cfg $VOL_BASE_DIR/bsc/
	cp generic/osmo-bts.gen.cfg $VOL_BASE_DIR/bts/
	network_replace_subnet_in_configs

	start_bsc
	start_bts trx 1
	start_fake_trx
	start_trxcon

	start_testsuite hopping

	docker_kill_wait ${BUILD_TAG}-trxcon
	docker_kill_wait ${BUILD_TAG}-fake_trx
	docker_kill_wait ${BUILD_TAG}-bsc
	docker_kill_wait ${BUILD_TAG}-bts
}

network_create

mkdir $VOL_BASE_DIR/bts-tester-generic
cp generic/BTS_Tests.cfg $VOL_BASE_DIR/bts-tester-generic/
write_mp_osmo_repo "$VOL_BASE_DIR/bts-tester-generic/BTS_Tests.cfg"
set_pcuif_version "$VOL_BASE_DIR/bts-tester-generic/BTS_Tests.cfg"
mkdir $VOL_BASE_DIR/bts-tester-virtphy
cp virtphy/BTS_Tests.cfg $VOL_BASE_DIR/bts-tester-virtphy/
write_mp_osmo_repo "$VOL_BASE_DIR/bts-tester-virtphy/BTS_Tests.cfg"
set_pcuif_version "$VOL_BASE_DIR/bts-tester-virtphy/BTS_Tests.cfg"
mkdir $VOL_BASE_DIR/bts-tester-oml
cp oml/BTS_Tests.cfg $VOL_BASE_DIR/bts-tester-oml/
write_mp_osmo_repo "$VOL_BASE_DIR/bts-tester-oml/BTS_Tests.cfg"
set_pcuif_version "$VOL_BASE_DIR/bts-tester-oml/BTS_Tests.cfg"
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

mkdir $VOL_BASE_DIR/unix

mkdir $VOL_BASE_DIR/fake_trx
mkdir $VOL_BASE_DIR/trxcon
mkdir $VOL_BASE_DIR/virtphy

start_config_generic
start_config_virtphy
start_config_oml
start_config_hopping
