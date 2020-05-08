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
	# Clean previous sources
	if [ -d "rpmbuild/SOURCES" ]; then
		rm -rf "rpmbuild/SOURCES"
	fi

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

	# Copy spec file
	require_path "$specfile"
	cp "$specfile" "rpmbuild/SPECS/$pkgname.spec"

	# Copy source files (patches etc.)
	for i in "spec/$pkgname/"*; do
		case "$i" in
		*.spec)
			;;
		*)
			echo "add source: $i"
			cp -r "$i" "rpmbuild/SOURCES/"
		esac
	done

	# Install depends and build
	mkdir -p "cache/$IMAGE/dnf" "cache/distfiles"
	docker run \
		-it \
		--rm \
		-v "$DIR/rpmbuild:/home/user/rpmbuild" \
		-v "$DIR/scripts:/scripts" \
		-v "$DIR/cache/$IMAGE/dnf:/var/cache/dnf" \
		-v "$DIR/cache/distfiles:/home/user/distfiles" \
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
	echo "add source: git HEAD tarball: $tarball"

	require_path "$SRCDIR/$pkgname"
	git -C "$SRCDIR/$pkgname" archive \
		--format=tar \
		--prefix="$pkgname-$version/" \
		HEAD \
		> "$tarball"

	_build_pkg "$pkgname"
}

# $1: pkgname (e.g. ortp)
# $2-$n: path to source in $OSCDIR (e.g. ortp/ortp-0.24.2.tar.gz, leave empty if no source needed)
build_pkg_other() {
	local pkgname="$1"

	skip_pkg "$pkgname" && return
	mkdir_rpmbuild

	shift
	if [ -n "$1" ]; then
		for i in "$@"; do
			local tarball="$OSCDIR/$i"

			require_path "$tarball"
			echo "add source: $tarball"
			cp "$tarball" "rpmbuild/SOURCES/"
		done
	fi

	_build_pkg "$pkgname"
}

require_path "$SRCDIR"
require_path "$OSCDIR"
build_docker_image "$IMAGE"

#
# Build packages
#

# Compatibility with build dependency available in openSUSE
build_pkg_other "systemd-rpm-macros"

# ortp (dependency of libosmo-abis)
build_pkg_other "ortp" "ortp/ortp-0.24.2.tar.gz"

# uhd (dependency of osmo-bts)
build_pkg_other "python-cheetah"
build_pkg_other "uhd"

# limesuite (dependency of osmo-bts)
# needs wxwidgets
# build_pkg_other "limesuite" "limesuite/limesuite-20.01.0.tar.xz"

# libgtpnl (dependency of osmo-ggsn)
build_pkg_other libgtpnl "libgtpnl/libgtpnl-1.2.1.0.tar.xz"

# Osmocom libraries
build_pkg_osmo "libosmocore"
build_pkg_osmo "libosmo-abis"
build_pkg_osmo "libosmo-netif"
build_pkg_osmo "libsmpp34"
build_pkg_osmo "libasn1c"

# Osmocom RAN
build_pkg_osmo "osmo-bts"
build_pkg_osmo "osmo-trx"

# Osmocom CN
build_pkg_osmo "osmo-ggsn"
build_pkg_osmo "osmo-iuh"
build_pkg_osmo "osmo-hlr"
build_pkg_osmo "osmo-mgw"
build_pkg_osmo "osmo-msc"
build_pkg_osmo "osmo-bsc"
build_pkg_osmo "osmo-sgsn"
build_pkg_osmo "osmo-sip-connector"
