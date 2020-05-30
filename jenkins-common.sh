docker_image_exists() {
	test -n "$(docker images -q "$REPO_USER/$1")"
}

docker_depends() {
	case "$1" in
	osmo-*-centos8) echo "centos8-build" ;;
	osmo-*) echo "debian-stretch-build" ;;
	ttcn3-*) echo "debian-stretch-titan" ;;
	esac
}

docker_distro_from_image_name() {
	case "$1" in
	osmo-*-centos8) echo "centos8"; ;;
	*) echo "debian-stretch" ;;
	esac

}

docker_dir_from_image_name() {
	case "$1" in
	osmo-*-centos8) echo "$1" | sed 's/\-centos8$//' ;;
	*) echo "$1" ;;
	esac
}

# Make sure required images are available and build them if necessary.
# $*: image names (e.g. "debian-stretch-build", "osmo-mgw-master", "osmo-mgw-master-centos8")
#	The images are automatically built from the Dockerfile of the subdir of the same name. If there is a
#	distribution name at the end of the image name (e.g. osmo-mgw-master-centos8), it gets removed from the subdir
#	where the Dockerfile is taken from (e.g. osmo-mgw-master/Dockerfile) and DISTRO is passed accordingly
#	(e.g. DISTRO=centos8). This allows one Dockerfile for multiple distributions, without duplicating configs for
#	each distribution. Dependencies listed in docker_depends() are built automatically too.
docker_images_require() {
	local i
	local from_line
	local pull_arg
	local distro_arg
	local depends
	local dir

	for i in $@; do
		# Build dependencies first
		depends="$(docker_depends "$i")"
		if [ -n "$depends" ]; then
			docker_images_require $depends
		fi

		# Trigger image build (cache will be used when up-to-date)
		if [ -z "$NO_DOCKER_IMAGE_BUILD" ]; then
			distro_arg="$(docker_distro_from_image_name "$i")"
			dir="$(docker_dir_from_image_name "$i")"

			# Pull upstream base images
			pull_arg="--pull"
			from_line="$(grep '^FROM' ../$dir/Dockerfile)"
			if echo "$from_line" | grep -q '$USER'; then
				pull_arg=""
			fi

			echo "Building image: $i (export NO_DOCKER_IMAGE_BUILD=1 to prevent this)"
			make -C "../$dir" \
				PULL="$pull_arg" \
				DISTRO="$distro_arg" \
				IMAGE="$REPO_USER/$i" \
				|| exit 1
		fi

		# Detect missing images (build skipped)
		if ! docker_image_exists "$i"; then
			echo "ERROR: missing image: $i"
			exit 1
		fi
	done
}

#kills all containers attached to network
network_clean() {
	docker network inspect $NET_NAME | grep Name | cut -d : -f2 | awk -F\" 'NR>1{print $2}' | xargs -rn1 docker kill
}

network_create() {
	NET=$1
	if docker network ls | grep -q $NET_NAME; then
		echo removing stale network and containers...
		network_clean
		network_remove
	fi
	echo Creating network $NET_NAME
	docker network create --internal --subnet $NET $NET_NAME
}

network_remove() {
	echo Removing network $NET_NAME
	docker network remove $NET_NAME
}

fix_perms() {
	if ! docker_image_exists "debian-stretch-build"; then
		docker_images_require "debian-stretch-build"
	fi

	echo Fixing permissions
	docker run 	--rm \
			-v $VOL_BASE_DIR:/data \
			--name ${BUILD_TAG}-cleaner \
			$REPO_USER/debian-stretch-build \
			chmod -R a+rX /data/
}

collect_logs() {
	fix_perms
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
