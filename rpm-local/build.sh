#!/bin/sh -e
DIR="$(cd "$(dirname "$0")" && pwd -P)"
# Sources (in libosmocore, osmo-bts, ... subdirs)
SRCDIR="$(realpath "$DIR/../../")"
IMAGE="centos8"

require_path() {
	if ! [ -e "$1" ]; then
		echo "ERROR: path not found: $1" >&2
		exit 1
	fi
}

build_docker_image() {
	if [ -e ".build.docker.$IMAGE" ]; then
		return
	fi
	require_path "images/$IMAGE/Dockerfile"

	( cd "$DIR/images"
	  docker build --build-arg "UID=$(id -u)" -t "$IMAGE:latest" "$IMAGE" )

	touch ".build.docker.$IMAGE"
}

# $1: path to spec file
spec_version() {
	require_path "$1"
	grep '^Version:' "$1" | cut -d ':' -f 2 | xargs
}

# $1: osmocom git repo name
build_pkg() {
	local pkgname="$1"
	local specfile="spec/$pkgname/$pkgname.spec"
	local version

	if [ -e ".build.package.$pkgname" ]; then
		echo ":: $pkgname (already built)"
		return
	fi

	echo ":: $pkgname"

	require_path "$SRCDIR/$pkgname"
	require_path "$specfile"

	# Create temporary rpmbuild with spec
	mkdir -p \
		"rpmbuild/RPMS" \
		"rpmbuild/SOURCES" \
		"rpmbuild/SPECS" \
		"rpmbuild/SRPMS"
	cp -r "$specfile" "rpmbuild/SPECS/$pkgname.spec"

	# Create source tarball
	version="$(spec_version "$specfile")"
	git -C "$SRCDIR/$pkgname" archive \
		--format=tar \
		--prefix="$pkgname-$version/" \
		HEAD \
		> "rpmbuild/SOURCES/$pkgname-$version.tar.xz"

	# Install depends and build
	mkdir -p "cache/$IMAGE/dnf"
	docker run \
		-it \
		--rm \
		-v "$DIR/rpmbuild:/home/user/rpmbuild" \
		-v "$DIR/scripts:/scripts" \
		-v "$DIR/cache/$IMAGE/dnf:/var/cache/dnf" \
		"$IMAGE:latest" \
		/scripts/build_pkg.sh "$pkgname"

	touch ".build.package.$pkgname"
}

require_path "$SRCDIR"
build_docker_image "$IMAGE"

build_pkg "libosmocore"
build_pkg "libosmo-abis"
