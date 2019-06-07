#!/bin/sh +x

. ../jenkins-common.sh

NAME="$1"
PORT="$2"
COUNTERFILE="$3"
VTYFILE="$4"

IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
if [ -z "$OSMO_INTERACT_VTY" ]; then
	OSMO_INTERACT_VTY="osmo-interact-vty.py"
fi

docker_images_require \
	"$NAME-$IMAGE_SUFFIX"

network_create 172.18.12.0/24

container_create() {
	CONTAINERNAME=$1
	IP_ADDR=$2

	docker run --rm --network ${NET_NAME} --ip ${IP_ADDR} \
		--name ${BUILD_TAG}-${CONTAINERNAME} -d \
		${REPO_USER}/${CONTAINERNAME}


}

container_create "$NAME-$IMAGE_SUFFIX" 172.18.12.23

# Get asciidoc counter info
${OSMO_INTERACT_VTY} \
	-c "enable;show asciidoc counters" -p "$PORT" -H 172.18.12.23 -O "$COUNTERFILE"

# Get vty reference
${OSMO_INTERACT_VTY} \
	-X -p "$PORT" -H 172.18.12.23 -O "$VTYFILE"

docker container kill "${BUILD_TAG}-$NAME-$IMAGE_SUFFIX"

network_remove
