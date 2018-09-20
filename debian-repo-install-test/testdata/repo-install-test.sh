#!/bin/sh -ex

HTTP="http://download.opensuse.org/repositories/network:/osmocom:/$FEED/Debian_9.0/"
OBS="obs://build.opensuse.org/network:osmocom:$FEED/Debian_9.0"

check_env() {
	if [ -n "$FEED" ]; then
		echo "Checking feed: $FEED"
	else
		echo "ERROR: missing environment variable \$FEED!"
		exit 1
	fi
}

install_depends() {
	echo "Installing dependencies"
	apt-get update
	apt-get install -y gnupg aptitude
}

configure_osmocom_repo() {
	echo "Configuring Osmocom repository"
	apt-key add /testdata/Release.key
	echo "deb $HTTP ./" \
		> /etc/apt/sources.list.d/osmocom-latest.list
	apt-get update
}

install_repo_packages() {
	echo "Installing all repository packages"

	# Get a list of all packages from the repository. Reference:
	# https://www.debian.org/doc/manuals/aptitude/ch02s04s05.en.html
	aptitude search -F%p \
		"?origin($OBS) ?architecture(native)" | sort \
		> /data/osmocom_packages_all.txt

	# Remove comments from blacklist.txt (and sort it)
	grep -v "^#" /testdata/blacklist.txt | sort -u > /data/blacklist.txt

	# Install all repo packages which are not on the blacklist
	comm -23 /data/osmocom_packages_all.txt \
		/data/blacklist.txt > /data/osmocom_packages.txt
	apt install -y $(cat /data/osmocom_packages.txt)
}

test_binaries_version() {
	# Make sure --version runs and does not output UNKNOWN
	failed=""
	for program in $@; do
		# Make sure it runs at all
		$program --version

		# Check for UNKNOWN
		if $program --version | grep -q UNKNOWN; then
			failed="$failed $program"
			echo "ERROR: this program prints UNKNOWN in --version!"
		fi
	done

	if [ -n "$failed" ]; then
		echo "ERROR: the following program(s) print UNKNOWN in --version:"
		echo "$failed"
		return 1
	fi
}

test_binaries() {
	# Make sure the binaries are not broken (run -h or --version)
	osmo-gtphub -h
	osmo-sip-connector -h
	osmo-trx-uhd -h
	osmo-trx-usrp1 -h

	test_binaries_version \
		osmo-bsc \
		osmo-bts-trx \
		osmo-bts-virtual \
		osmo-gbproxy \
		osmo-ggsn \
		osmo-hlr \
		osmo-hlr-db-tool \
		osmo-hnbgw \
		osmo-mgw \
		osmo-msc \
		osmo-pcu \
		osmo-sgsn \
		osmo-stp
}

finish() {
	echo "Test finished successfully!"

	# When docker-run is called with "-it", then stdin and a tty are available.
	# The container will still exit when the entrypoint script (this file) is
	# through, so in order to be able to type in commands, we execute a bash shell.
	if [ -t 0 ]; then
		echo "Dropping to interactive shell"
		bash
	fi
}

check_env
install_depends
configure_osmocom_repo
install_repo_packages
test_binaries
finish
