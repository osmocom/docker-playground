#!/bin/bash

. ../../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX?centos8}"
if [ "x$IMAGE_SUFFIX" != "x" ]; then
	IMAGE_SUFFIX="-${IMAGE_SUFFIX}" # append dash
fi

IMAGE_DIR_PREFIX="../.." docker_images_require \
	"systemd"

networks=()
docker_names=()

SUBNET=${SUBNET:-25}

NET_NAME="osmo-ran-subnet$subnet"
networks+=("$NET_NAME")
network_bridge_create $SUBNET

#$1:image_name, $2: subnet, $3: ip suffix, $4: docker args
run_image() {
	local image_name=$1
	local subnet=$2
	local ipsuffix=$3
	local docker_args=$4

	IMAGE_DIR_PREFIX="."
	docker_images_require \
		$image_name

	VOL_RAN_DIR="$VOL_BASE_DIR/$image_name-$subnet"
	mkdir $VOL_RAN_DIR
	mkdir $VOL_RAN_DIR/data
	mkdir $VOL_RAN_DIR/osmocom
	cp $IMAGE_DIR_PREFIX/${image_name}/osmocom/* $VOL_RAN_DIR/osmocom/

	DOCKER_IN_IP="172.18.$subnet.$ipsuffix"
	SGSN_IP="${SGSN_IP:-192.168.30.1}"
	STP_IP="${STP_IP:-192.168.30.1}"
	BSC_IP="172.18.$SUBNET.200"
	MGW_IP="172.18.$SUBNET.200"
	BTS_IP="172.18.$SUBNET.201"
	PCU_IP="172.18.$SUBNET.201"
	TRX_IP="${TRX_IP:-172.18.$SUBNET.202}"
	sed -i "s/\$DOCKER_IN_IP/${DOCKER_IN_IP}/g" $VOL_RAN_DIR/osmocom/*
	sed -i "s/\$SGSN_IP/${SGSN_IP}/g" $VOL_RAN_DIR/osmocom/*
	sed -i "s/\$STP_IP/${STP_IP}/g" $VOL_RAN_DIR/osmocom/*
	sed -i "s/\$BSC_IP/${BSC_IP}/g" $VOL_RAN_DIR/osmocom/*
	sed -i "s/\$MGW_IP/${MGW_IP}/g" $VOL_RAN_DIR/osmocom/*
	sed -i "s/\$BTS_IP/${BTS_IP}/g" $VOL_RAN_DIR/osmocom/*
	sed -i "s/\$PCU_IP/${PCU_IP}/g" $VOL_RAN_DIR/osmocom/*
	sed -i "s/\$TRX_IP/${TRX_IP}/g" $VOL_RAN_DIR/osmocom/*

	echo Starting container with RAN
	docker_name="${BUILD_TAG}-ran-${image_name}-subnet$subnet"
	docker run	--rm \
			$(docker_network_params $subnet $ipsuffix) \
			--privileged \
			--ulimit core=-1 \
			-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
			-v $VOL_RAN_DIR/data:/data \
			-v $VOL_RAN_DIR/osmocom:/etc/osmocom \
			--name ${docker_name} -d \
			$docker_args \
			$REPO_USER/${image_name}${IMAGE_SUFFIX}
	docker_names+=("$docker_name")
}

kill_containers() {
	for i in "${docker_names[@]}"; do
		docker kill $i
	done
}

remove_networks() {
	for i in "${networks[@]}"; do
		NET_NAME="$i"
		network_remove
	done
}

sighandler() {
	echo "SIGINT, exiting..."
	kill_containers
	remove_networks
	exit 0
}

trap 'sighandler' SIGINT

run_image "ran-bsc_mgw" $SUBNET 200 "-p 4242:4242 -p 4249:4249 -p 4243:4243 -p 4267:4267"
run_image "ran-bts_pcu" $SUBNET 201 "-p 4241:4241 -p 4238:4238 -p 4240:4240"
run_image "ran-trx-uhd" $SUBNET 202 "-p 4237:4237 -p 4236:4236 -p 5700:5700 -p 5701:5701 -p 5702:5702 -v /dev/bus/usb:/dev/bus/usb"
#run_image "ran-trx-ipc" $SUBNET 202 "-p 4237:4237 -p 4236:4236 -p 5700:5700 -p 5701:5701 -p 5702:5702 -v /tmp/ud:/tmp/ud --ipc=host"

while true; do sleep 1000; done
