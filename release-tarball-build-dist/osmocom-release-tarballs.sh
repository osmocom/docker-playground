#!/bin/sh -e
# Iterate over all relevant Osmocom repositories and generate release tarballs for each of the repository tags. The tags
# are queried from the git server without cloning the repositories first, so we can clone them only if we need to build
# a missing tarball. All repositories are deleted afterwards to save space.
#
# Environment variables:
# * KEEP_TEMP: do not delete cloned repositories (use for development)
# * PARALLEL_MAKE: -jN argument for make (default: -j5).
SSH_COMMAND="ssh -o UserKnownHostsFile=/build/known_hosts -p 48"
OSMO_GIT_URL="https://git.osmocom.org"
OSMO_RELEASE_REPOS="
	libasn1c
	libosmo-abis
	libosmo-netif
	libosmo-sccp
	libosmocore
	libsmpp34
	libusrp
	osmo-bsc
	osmo-bts
	osmo-cbc
	osmo-e1d
	osmo-gbproxy
	osmo-ggsn
	osmo-gsm-manuals
	osmo-hlr
	osmo-hnodeb
	osmo-hnbgw
	osmo-iuh
	osmo-mgw
	osmo-msc
	osmo-pcap
	osmo-pcu
	osmo-remsim
	osmo-sgsn
	osmo-sip-connector
	osmo-smlc
	osmo-sysmon
	osmo-trx
	osmo-uecups
	osmocom-bb
	simtrace2
"

# Print last tags and related commits for an Osmocom git repository, e.g.:
# "ec798b89700dcca5c5b28edf1a1cd16ea311f30a        refs/tags/1.0.1"
# $1: Osmocom repository
# $2: amount of commit, tag pairs to print (default: 1, set to "all" to print all)
# $3: string to print when there are no tags (default: empty string)
osmo_git_last_commits_tags() {
	# git output:
	# ec798b89700dcca5c5b28edf1a1cd16ea311f30a        refs/tags/1.0.1
	# eab5f594b0a7cf50ad97b039f73beff42cc8312a        refs/tags/1.0.1^{}
	# ...
	# 41e7cf115d4148a9f34fcb863b68b2d5370e335d        refs/tags/1.3.1^{}
	# 8a9f12dc2f69bf3a4e861cc9a81b71bdc5f13180        refs/tags/3G_2016_09
	# ee618ecbedec82dfd240334bc87d0d1c806477b0        refs/tags/debian/0.9.13-0_jrsantos.1
	# a3fdd24af099b449c9856422eb099fb45a5595df        refs/tags/debian/0.9.13-0_jrsantos.1^{}
	# ...
	ret="$(git ls-remote --tags "$OSMO_GIT_URL/$1")"
	ret="$(echo "$ret" | grep 'refs/tags/[0-9.]*$' || true)"
	ret="$(echo "$ret" | sort -V -t/ -k3)"
	if [ "$2" != "all" ]; then
		ret="$(echo "$ret" | tail -n "$2")"
	fi

	if [ -n "$ret" ]; then
		echo "$ret"
	else
		echo "$3"
	fi
}


cd "$(dirname "$0")"
PARALLEL_MAKE="${PARALLEL_MAKE:--j5}"
OUTPUT="/build/_release_tarballs"
TEMP="/build/_temp"

# Print all tags for which no release tarball should be built.
# $1: Osmocom repository
tags_to_ignore() {
	case "$1" in
		libosmocore)
			# configure.ac:144: error: required file 'src/gb/Makefile.in' not found
			echo "0.5.0"
			echo "0.5.1"
			;;
		libsmpp34)
			# duplicate of 1.12.0
			echo "1.12"
			;;
		osmo-bsc)
			# openbsc
			echo "1.0.1"
			# Requires libosmo-legacy-mgcp
			echo "1.1.0"
			echo "1.1.1"
			echo "1.1.2"
			echo "1.2.0"
			echo "1.2.1"
			echo "1.2.2"
			;;
		osmo-bts)
			# gsm_data_shared.h:464:26: error: field 'power_params' has incomplete type
			echo "0.2.0"
			echo "0.3.0"
			;;
		osmo-hlr)
			# Not using autotools
			echo "0.0.1"
			;;
		osmo-mgw)
			# openbsc
			echo "1.0.1"
			;;
		osmo-msc)
			# openbsc
			echo "1.0.1"
			;;
		osmo-pcap)
			# No rule to make target 'osmo-pcap-server.cfg', needed by 'distdir'
			echo "0.0.3"
			;;
		osmo-pcu)
			# Duplicates of 0.1.0, 0.2.0
			echo "0.1"
			echo "0.2"
			;;
		osmo-sgsn)
			# openbsc
			echo "0.9.0 0.9.1 0.9.2 0.9.3 0.9.4 0.9.5 0.9.6 0.9.8 0.9.9 0.9.10 0.9.11 0.9.12 0.9.13 0.9.14"
			echo "0.9.15 0.9.16 0.10.0 0.10.1 0.11.0 0.12.0 0.13.0 0.14.0 0.15.0 1.0.1"
			;;
		osmo-sip-connector)
			# make: *** No rule to make target 'osmoappdesc.py'
			echo "0.0.1"
			;;
		osmo-trx)
			# cp: cannot stat './/home/user/code/osmo-dev/src/osmo-ci/_temp/repos/osmo-trx/configure'
			echo "0.2.0"
			echo "0.3.0"
			echo "1.3.0"
			;;
	esac
}

# Clone dependency repositories.
# $1: Osmocom repository
prepare_depends() {
	case "$1" in
		osmo-bts)
			# Includes openbsc/gsm_data_shared.h
			prepare_repo "openbsc"
			;;
	esac
}

# Apply workarounds for bugs that break too many releases. This function runs between ./configure and make dist-bzip2.
# $1: Osmocom repository
fix_repo() {
	case "$1" in
		osmo-mgw)
			# No rule to make target 'osmocom/mgcp_client/mgcp_common.h' (OS#4084)
			make -C "$TEMP/repos/$1/include/osmocom/mgcp_client" mgcp_common.h || true
			;;
	esac
}

# Check if one specific tag should be ignored.
# $1: Osmocom repository
# $2: tag (e.g. "1.0.0")
ignore_tag() {
	local repo="$1"
	local tag="$2"
	local tags="$(tags_to_ignore "$repo")"
	for tag_i in $tags; do
		if [ "$tag" = "$tag_i" ]; then
			return 0
		fi
	done
	return 1
}

# Delete existing temp dir (unless KEEP_TEMP is set). If all repos were checked out, this restores ~500 MB of space.
remove_temp_dir() {
	if [ -n "$KEEP_TEMP" ]; then
		echo "NOTE: not removing temp dir, because KEEP_TEMP is set: $TEMP"
	elif [ -d "$TEMP" ]; then
		rm -rf "$TEMP"
	fi
}

# Clone an Osmocom repository to $TEMP/repos/$repo, clean it, checkout a tag.
# $1: Osmocom repository (may end in subdir, e.g. simtrace2/host)
# $2: tag (optional, default: master)
prepare_repo() {
	local repo="$1"
	local tag="${2:-master}"

	if ! [ -d "$TEMP/repos/$repo" ]; then
		git -C "$TEMP/repos" clone "$OSMO_GIT_URL/$repo"
	fi

	cd "$TEMP/repos/$repo"
	git clean -qdxf
	git reset --hard HEAD # in case the tracked files were modified (e.g. libsmpp34 1.10)
	git checkout -q "$tag"
}


# Get the desired tarball name, replace / with - in $1.
# $1: Osmocom repository (may end in subdir, e.g. simtrace2/host)
# $2: tag
tarball_name() {
	echo "$(echo "$repo" | tr / -)-$tag.tar.bz2"
}

# Checkout a given tag and build a release tarball.
# $1: Osmocom repository (may end in subdir, e.g. simtrace2/host)
# $2: tag
create_tarball() {
	local repo="$1"
	local tag="$2"
	local tarball="$(tarball_name "$repo" "$tag")"

	# Be verbose during the tarball build and preparation. Everything else is not verbose, so we can generate an
	# easy to read overview of tarballs that are already built or are ignored.
	set -x

	prepare_repo "$repo" "$tag"
	prepare_depends "$repo"

	cd "$TEMP/repos/$repo"
	autoreconf -fi
	./configure
	fix_repo "$repo"
	make dist-bzip2

	# Back to non-verbose mode
	set +x

	if ! [ -e "$tarball" ]; then
		echo "NOTE: tarball has a different name (wrong version in configure.ac?), renaming."
		mv -v *.tar.bz2 "$tarball"
	fi
}

# Create a release tarball with "git archive" for non-autotools projects.
# $1: Osmocom repository
# $2: tag
create_tarball_git() {
	local repo="$1"
	local tag="$2"
	local tarball="$(tarball_name "$repo" "$tag")"

	set -x

	cd "$TEMP/repos/$repo"
	git archive \
		-o "$tarball" \
		"$tag"

	set +x
}

# Move a generated release tarball to the output dir.
# $1: Osmocom repository (may end in subdir, e.g. simtrace2/host)
# $2: tag
move_tarball() {
	local repo="$1"
	local tag="$2"
	local tarball="$(tarball_name "$repo" "$tag")"
	local repo_dir="$(echo "$repo" | cut -d / -f 1)"

	cd "$TEMP/repos/$repo"
	mkdir -p "$OUTPUT/$repo_dir"
	mv "$tarball" "$OUTPUT/$repo_dir/$tarball"
}

# Check if a git tag has a specific file
# $1: Osmocom repository
# $2: tag
# $3: file
tag_has_file() {
	local repo="$1"
	local tag="$2"
	local file="$3"

	git -C "$TEMP/repos/$repo" show "$tag:$file" >/dev/null 2>&1
}

# Create and move tarballs for Osmocom repositories.
# $1: Osmocom repository
# $2: tag
create_move_tarball() {
	local repo="$1"
	local tag="$2"

	case "$repo" in
		simtrace2)
			if tag_has_file "$repo" "$tag" host/configure.ac; then
				create_tarball "$repo/host" "$tag"
				move_tarball "$repo/host" "$tag"
			else
				prepare_repo "$repo"
			fi

			create_tarball_git "$repo" "$tag"
			move_tarball "$repo" "$tag"
			;;
		*)
			create_tarball "$repo" "$tag"
			move_tarball "$repo" "$tag"
			;;
	esac
}

upload() {
	cd _release_tarballs
	rsync -avz --delete -e "$SSH_COMMAND" . releases@ftp.osmocom.org:web-files/
}

remove_temp_dir
mkdir -p "$TEMP/repos"
echo "Temp dir: $TEMP"

for repo in $OSMO_RELEASE_REPOS; do
	echo "$repo"
	tags="$(osmo_git_last_commits_tags "$repo" "all" | cut -d / -f 3)"

	# Skip untagged repos
	if [ -z "$tags" ]; then
		echo "  (repository has no release tags)"
		continue
	fi

	# Build missing tarballs for each tag
	for tag in $tags; do
		tarball="$repo-$tag.tar.bz2"
		if ignore_tag "$repo" "$tag"; then
			echo "  $tarball (ignored)"
			continue
		elif [ -e "$OUTPUT/$repo/$tarball" ]; then
			echo "  $tarball (exists)"
			continue
		fi

		echo "  $tarball (creating)"
		create_move_tarball "$repo" "$tag"
	done
done

remove_temp_dir
upload
echo "done!"
