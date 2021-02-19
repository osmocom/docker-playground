#!/bin/sh

. ../jenkins-common.sh

set_clean_up_trap

clean_up() {
	# start some stupid helper container so we can access the volume
	docker run	--rm \
		-v ttcn3-nitb-sysinfo-vol:/ttcn3-nitb-sysinfo \
		-v nitb-vol:/nitb \
		-v bts-vol:/bts \
		--name ${BUILD_TAG}-sysinfo-helper -d \
		busybox /bin/sh -c 'sleep 1000 & wait'
	docker cp ${BUILD_TAG}-sysinfo-helper:/ttcn3-nitb-sysinfo $VOL_BASE_DIR
	docker cp ${BUILD_TAG}-sysinfo-helper:/nitb $VOL_BASE_DIR
	docker cp ${BUILD_TAG}-sysinfo-helper:/bts $VOL_BASE_DIR
	docker container stop -t 0 ${BUILD_TAG}-sysinfo-helper
}

SUBNET=5
network_create $SUBNET

# start container with nitb in background
docker volume rm nitb-vol
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v nitb-vol:/data \
		--name ${BUILD_TAG}-nitb -d \
		$REPO_USER/osmo-nitb-master

# start container with bts in background
docker volume rm bts-vol
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		$(docker_network_params $SUBNET 210) \
		--ulimit core=-1 \
		-v bts-vol:/data \
		--name ${BUILD_TAG}-bts -d \
		$REPO_USER/osmo-bts-master


# start docker container with testsuite in foreground
docker volume rm ttcn3-nitb-sysinfo-vol
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		$(docker_network_params $SUBNET 230) \
		--ulimit core=-1 \
		-v ttcn3-nitb-sysinfo-vol:/data \
		--name ${BUILD_TAG}-ttcn3-nitb-sysinfo \
		$REPO_USER/ttcn3-nitb-sysinfo
