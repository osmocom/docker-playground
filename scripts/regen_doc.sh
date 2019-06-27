#!/bin/sh +x

. ../jenkins-common.sh

NAME="$1"
PORT="$2"
COUNTERFILE="$3"
VTYFILE="$4"
DOCKER_EXTRA="$5"

IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
if [ -z "$OSMO_INTERACT_VTY" ]; then
	OSMO_INTERACT_VTY="osmo_interact_vty.py"
fi
if ! command -v "$OSMO_INTERACT_VTY" 2>&1; then
	set +x
	echo "ERROR: $OSMO_INTERACT_VTY not found. Are osmo-python-tests in PATH?"
	exit 1
fi

docker_images_require \
	"$NAME-$IMAGE_SUFFIX"

network_create 172.18.12.0/24

container_create() {
	CONTAINERNAME=$1
	IP_ADDR=$2

	docker run --rm --network ${NET_NAME} --ip ${IP_ADDR} \
		--name ${BUILD_TAG}-${CONTAINERNAME} -d \
		${REPO_USER}/${CONTAINERNAME} \
		${DOCKER_EXTRA}


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
