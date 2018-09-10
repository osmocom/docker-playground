#!/bin/sh
. ../jenkins-common.sh

# Configuration
[ -z "$FEED" ] && FEED="nightly"
interactive="false"

# Run the container
extra_args=""
[ "$interactive" = "true" ] && extra_args="-it"
docker run	--rm \
		-v "$PWD/testdata:/testdata:ro" \
		-v "$VOL_BASE_DIR:/data" \
		--name "${BUILD_TAG}" \
		-e FEED="$FEED" \
		$extra_args \
		debian:stretch \
		"/testdata/repo-install-test.sh"
