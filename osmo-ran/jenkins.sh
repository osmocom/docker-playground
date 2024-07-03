#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX?centos8}"
if [ "x$IMAGE_SUFFIX" != "x" ]; then
	IMAGE_SUFFIX="-${IMAGE_SUFFIX}" # append dash
fi
docker_images_require \
	"systemd" \
	"osmo-ran$IMAGE_SUFFIX"

SUB4_PREFIX=${SUB4_PREFIX:-"172.18"}
SUBNET=${SUBNET:-25}
IPSUFFIX=200
NET_NAME="osmo-ran-subnet$SUBNET"
network_bridge_create $SUBNET

VOL_RAN_DIR="$VOL_BASE_DIR/ran-$SUBNET"
mkdir $VOL_RAN_DIR
mkdir $VOL_RAN_DIR/data
mkdir $VOL_RAN_DIR/osmocom
cp osmocom/* $VOL_RAN_DIR/osmocom/

DOCKER_IN_IP="$SUB4_PREFIX.$SUBNET.$IPSUFFIX"
SGSN_IP="${SGSN_IP:-192.168.30.1}"
STP_IP="${STP_IP:-192.168.30.1}"
TRX_IP="${TRX_IP:-192.168.30.100}"
sed -i "s/\$DOCKER_IN_IP/${DOCKER_IN_IP}/g" $VOL_RAN_DIR/osmocom/*
sed -i "s/\$SGSN_IP/${SGSN_IP}/g" $VOL_RAN_DIR/osmocom/*
sed -i "s/\$STP_IP/${STP_IP}/g" $VOL_RAN_DIR/osmocom/*
sed -i "s/\$TRX_IP/${TRX_IP}/g" $VOL_RAN_DIR/osmocom/*

echo Starting container with RAN
docker run	--rm \
		$(docker_network_params $SUBNET 200) \
		--privileged \
		--ulimit core=-1 \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		-v $VOL_RAN_DIR/data:/data \
		-v $VOL_RAN_DIR/osmocom:/etc/osmocom \
		-p 4242:4242 -p 4249:4249 \
		-p 4241:4241 -p 4238:4238 \
		-p 4243:4243 -p 4267:4267 \
		-p 4240:4240 -p 23010:23010 \
		--name ${BUILD_TAG}-ran-subnet$SUBNET \
		$DOCKER_ARGS \
		$REPO_USER/osmo-ran$IMAGE_SUFFIX
network_remove
