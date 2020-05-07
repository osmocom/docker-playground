#!/bin/sh -e
DIR="$(cd "$(dirname "$0")" && pwd -P)"
# Sources (in libosmocore, osmo-bts, ... subdirs)
SRCDIR="$(realpath "$DIR/../../")"
# Non-Osmocom sources (ortp/ortp-0.24.2.tar.gz, ...), download with 'osc co home:mnhauke:osmocom:nightly'
OSCDIR="/home/user/code/obs/home:mnhauke:osmocom:nightly"
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

mkdir_rpmbuild() {
	mkdir -p \
		"rpmbuild/RPMS" \
		"rpmbuild/SOURCES" \
		"rpmbuild/SPECS" \
		"rpmbuild/SRPMS"
}

# $1: pkgname (e.g. libosmocore)
skip_pkg() {
	if [ -e ".build.package.$1" ]; then
		echo ":: $pkgname (already built)"
		return 0
	fi
	echo ":: $pkgname"
	return 1
}

# $1: osmocom git repo name
_build_pkg() {
	local pkgname="$1"
	local specfile="spec/$pkgname/$pkgname.spec"

	require_path "$specfile"
	cp "$specfile" "rpmbuild/SPECS/$pkgname.spec"

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

# $1: pkgname (e.g. libosmocore)
build_pkg_osmo() {
	local pkgname="$1"
	local specfile="spec/$pkgname/$pkgname.spec"
	local version

	skip_pkg "$pkgname" && return
	mkdir_rpmbuild

	version="$(spec_version "$specfile")"
	tarball="rpmbuild/SOURCES/$pkgname-$version.tar.xz"
	echo "creating tarball from git HEAD: $tarball"

	require_path "$SRCDIR/$pkgname"
	git -C "$SRCDIR/$pkgname" archive \
		--format=tar \
		--prefix="$pkgname-$version/" \
		HEAD \
		> "$tarball"

	_build_pkg "$pkgname"
}

# $1: pkgname (e.g. ortp)
# $2: path to source in $OSCDIR (e.g. ortp/ortp-0.24.2.tar.gz)
build_pkg_other() {
	local pkgname="$1"
	local tarball="$OSCDIR/$2"

	skip_pkg "$pkgname" && return
	mkdir_rpmbuild

	require_path "$tarball"
	cp "$tarball" "rpmbuild/SOURCES/"

	_build_pkg "$pkgname"
}

require_path "$SRCDIR"
require_path "$OSCDIR"
build_docker_image "$IMAGE"

build_pkg_osmo "libosmocore"
build_pkg_other "ortp" "ortp/ortp-0.24.2.tar.gz"
build_pkg_osmo "libosmo-abis"
build_pkg_osmo "libosmo-netif"
build_pkg_osmo "libsmpp34"
build_pkg_osmo "libasn1c"

# RAN
build_pkg_osmo "osmo-bts"
build_pkg_osmo "osmo-trx"

# CN
build_pkg_osmo "osmo-ggsn"
build_pkg_osmo "osmo-iuh"
build_pkg_osmo "osmo-hlr"
build_pkg_osmo "osmo-mgw"
build_pkg_osmo "osmo-msc"
build_pkg_osmo "osmo-bsc"
build_pkg_osmo "osmo-sgsn"
build_pkg_osmo "osmo-sip-connector"
