#!/bin/sh -ex
. ../jenkins-common.sh

docker_images_require \
	"debian-bullseye-obs-latest" \
	"release-tarball-build-dist"

docker run \
	--rm=true \
	-v "$PWD:/build" \
	-v "$(readlink -f $SSH_AUTH_SOCK)":/ssh-agent \
	-w /osmo-ci \
	-e KEEP_TEMP="$KEEP_TEMP" \
	-e SSH_AUTH_SOCK=/ssh-agent \
	"$USER/release-tarball-build-dist" sh -e /build/osmocom-release-tarballs.sh

if [ -z "$WORKSPACE" ]; then
	set +x
	echo "NOTE: not running on jenkins, skipping upload"
fi
