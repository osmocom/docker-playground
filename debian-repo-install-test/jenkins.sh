#!/bin/sh
. ../jenkins-common.sh
docker_images_require "debian-repo-install-test"

[ -z "$FEED" ] && FEED="nightly"
CONTAINER="repo-install-test-$FEED"

# Try to run "systemctl status" 10 times, kill the container on failure
check_if_systemd_is_running() {
	for i in $(seq 1 10); do
		sleep 1
		if docker exec "$CONTAINER" systemctl status; then
			return
		fi
	done

	echo "ERROR: systemd is not running properly."
	docker container kill "$CONTAINER"
	exit 1
}

# Kill already running container
if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2> /dev/null)" = "true" ]; then
	docker container kill "$CONTAINER"
	sleep 1
fi

# Run the container
# * This does not output anything, for debugging add -it and remove &.
# * /run, /tmp, cgroups, SYS_ADMIN: needed for systemd
# * SYS_NICE: needed for changing CPUScheduling{Policy,Priority} (osmo-bts systemd service files)
docker run	--rm \
		-v "$PWD/testdata:/testdata:ro" \
		-v "$VOL_BASE_DIR:/data" \
		--name "$CONTAINER" \
		-e FEED="$FEED" \
		-e container=docker \
		--tmpfs /run \
		--tmpfs /tmp \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--cap-add SYS_ADMIN \
		--cap-add SYS_NICE \
		"$REPO_USER/debian-repo-install-test" \
		/lib/systemd/systemd &
check_if_systemd_is_running

# Run the test script
docker exec "$CONTAINER" /testdata/repo-install-test.sh
ret="$?"

# Interactive shell
if [ -n "$INTERACTIVE" ]; then
	docker exec -it "$CONTAINER" bash
fi

docker container kill "$CONTAINER"

exit $ret
