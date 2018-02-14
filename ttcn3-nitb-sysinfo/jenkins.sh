#!/bin/sh

. ../jenkins-common.sh

network_create 172.18.5.0/24

# start container with nitb in background
docker volume rm nitb-vol
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network $NET_NAME --ip 172.18.5.20 \
		-v nitb-vol:/data \
		--name ${BUILD_TAG}-nitb -d \
		$REPO_USER/osmo-nitb-master

# start container with bts in background
docker volume rm bts-vol
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network $NET_NAME --ip 172.18.5.210 \
		-v bts-vol:/data \
		--name ${BUILD_TAG}-bts -d \
		$REPO_USER/osmo-bts-master


# start docker container with testsuite in foreground
docker volume rm ttcn3-nitb-sysinfo-vol
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network $NET_NAME --ip 172.18.5.230 \
		-v ttcn3-nitb-sysinfo-vol:/data \
		--name ${BUILD_TAG}-ttcn3-nitb-sysinfo \
		$REPO_USER/ttcn3-nitb-sysinfo

# stop bts + nitb after test has completed
docker container stop ${BUILD_TAG}-bts
docker container stop ${BUILD_TAG}-nitb

# start some stupid helper container so we can access the volume
docker run	--rm \
		-v ttcn3-nitb-sysinfo-vol:/ttcn3-nitb-sysinfo \
		-v nitb-vol:/nitb \
		-v bts-vol:/bts \
		--name ${BUILD_TAG}-sysinfo-helper -d \
		busybox /bin/sh -c 'sleep 1000 & wait'
rm -rf $WORKSPACE/logs
mkdir -p $WORKSPACE/logs
docker cp ${BUILD_TAG}-sysinfo-helper:/ttcn3-nitb-sysinfo $WORKSPACE/logs
docker cp ${BUILD_TAG}-sysinfo-helper:/nitb $WORKSPACE/logs
docker cp ${BUILD_TAG}-sysinfo-helper:/bts $WORKSPACE/logs
docker container stop -t 0 ${BUILD_TAG}-sysinfo-helper

network_remove
