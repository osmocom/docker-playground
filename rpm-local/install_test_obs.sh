#!/bin/sh -ex
DIR="$(cd "$(dirname "$0")" && pwd -P)"
IMAGE="centos8"

if ! [ -e ".build.docker.$IMAGE" ]; then
	echo "ERROR: run build.sh first, to generate the docker img"
	exit 1
fi


docker run \
	-it \
	--rm \
	-v "$DIR/rpmbuild:/home/user/rpmbuild" \
	-v "$DIR/scripts:/scripts" \
	-v "$DIR/cache/$IMAGE/dnf:/var/cache/dnf" \
	-v "$DIR/cache/yum_repos:/root/yum_repos" \
	-v "$DIR/cache/distfiles:/home/user/distfiles" \
	"$IMAGE:latest" \
	/scripts/install_test_obs.sh
