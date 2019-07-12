#!/bin/sh
. ../jenkins-common.sh
docker_images_require "debian-repo-install-test"

[ -z "$FEED" ] && FEED="nightly"

# Try to run "systemctl status" 10 times, kill the container on failure
check_if_systemd_is_running() {
	for i in $(seq 1 10); do
		sleep 1
		if docker exec "$BUILD_TAG" systemctl status; then
			return
		fi
	done

	echo "ERROR: systemd is not running properly."
	docker container kill "$BUILD_TAG"
	exit 1
}

# Run the container
# Note that this does not output anything. For debugging, add -it and remove &.
docker run	--rm \
		-v "$PWD/testdata:/testdata:ro" \
		-v "$VOL_BASE_DIR:/data" \
		--name "${BUILD_TAG}" \
		-e FEED="$FEED" \
		-e container=docker \
		--tmpfs /run \
		--tmpfs /tmp \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--cap-add SYS_ADMIN \
		"$REPO_USER/debian-repo-install-test" \
		/lib/systemd/systemd &
check_if_systemd_is_running

# Run the test script
docker exec "$BUILD_TAG" /testdata/repo-install-test.sh
ret="$?"

# Interactive shell
if [ -n "$INTERACTIVE" ]; then
	docker exec -it "$BUILD_TAG" bash
fi

docker container kill "$BUILD_TAG"

exit $ret
