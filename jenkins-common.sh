docker_image_exists() {
	test -n "$(docker images -q "$REPO_USER/$1")"
}

docker_images_require() {
	for i in $@; do
		# Trigger image build (cache will be used when up-to-date)
		if [ -z "$NO_DOCKER_IMAGE_BUILD" ]; then
			echo "Building image: $i (export NO_DOCKER_IMAGE_BUILD=1 to prevent this)"
			make -C "../$i" || exit 1
		fi

		# Detect missing images (build skipped)
		if ! docker_image_exists "$i"; then
			echo "ERROR: missing image: $i"
			exit 1
		fi
	done
}

network_create() {
	NET=$1
	echo Creating network $NET_NAME
	docker network create --internal --subnet $NET $NET_NAME
}

network_remove() {
	echo Removing network $NET_NAME
	docker network remove $NET_NAME
}

collect_logs() {
	cat "$VOL_BASE_DIR"/*/junit-*.log || true
}

set -x

# non-jenkins execution: assume local user name
if [ "x$REPO_USER" = "x" ]; then
	REPO_USER=$USER
fi

if [ "x$WORKSPACE" = "x" ]; then
	# non-jenkins execution: put logs in /tmp
	VOL_BASE_DIR="$(mktemp -d)"

	# point /tmp/logs to the last ttcn3 run
	rm /tmp/logs || true
	ln -s "$VOL_BASE_DIR" /tmp/logs || true
else
	# jenkins execution: put logs in workspace
	VOL_BASE_DIR="$WORKSPACE/logs"
	rm -rf "$VOL_BASE_DIR"
	mkdir -p "$VOL_BASE_DIR"
fi

# non-jenkins execution: put logs in /tmp
if [ "x$BUILD_TAG" = "x" ]; then
	BUILD_TAG=nonjenkins
fi

SUITE_NAME=`basename $PWD`

NET_NAME=$SUITE_NAME
