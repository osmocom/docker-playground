#!/bin/sh

# This docket env allows running a typical osmo-gsm-tester setup with a main
# unit (ogt-master) running osmo-gsm-tester process, and using another docker
# container as a remote host where to run child processes.
#
# Trial directory must be set in the parent host's /tmp/trial path, which will
# then be mounted to ogt-master and used my osmo-gsm-tester.
#
# osmo-gsm-tester parameters and suites are passed in osmo-gsm-tester.sh in same
# directory as this script.
#
# Log files can be found in host's /tmp/logs/ directory.

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-stretch-build" \
	"osmo-gsm-tester"

network_create 172.18.50.0/24

mkdir $VOL_BASE_DIR/ogt-slave
cp osmo-gsm-tester-slave.sh $VOL_BASE_DIR/ogt-slave/

mkdir $VOL_BASE_DIR/ogt-master
cp osmo-gsm-tester-master.sh $VOL_BASE_DIR/ogt-master/

echo Starting container with osmo-gsm-tester slave
docker run	--rm \
		--cap-add=NET_ADMIN \
		--cap-add=SYS_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--network $NET_NAME \
		--ip 172.18.50.100 \
		-v $VOL_BASE_DIR/ogt-slave:/data \
		--name ${BUILD_TAG}-ogt-slave -d \
		$REPO_USER/osmo-gsm-tester \
		/bin/sh -c "/data/osmo-gsm-tester-slave.sh >/data/sshd.log 2>&1"

echo Starting container with osmo-gsm-tester main unit
docker run	--rm \
		--cap-add=NET_ADMIN \
		--cap-add=SYS_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--network $NET_NAME \
		--ip 172.18.50.2 \
		-v $VOL_BASE_DIR/ogt-master:/data \
		-v /tmp/trial:/tmp/trial \
		--name ${BUILD_TAG}-ogt-master \
		$REPO_USER/osmo-gsm-tester

echo Stopping containers
docker container kill ${BUILD_TAG}-ogt-slave

network_remove
collect_logs
