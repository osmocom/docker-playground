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

test_binaries() {
	# Make sure the binaries are not broken (run -h or --version)
	osmo-bsc --version
	osmo-bts-trx --version
	osmo-bts-virtual --version
	osmo-gbproxy --version
	osmo-ggsn --version
	osmo-gtphub -h
	osmo-hlr --version
	osmo-hlr-db-tool --version
	osmo-hnbgw --version
	osmo-mgw --version
	osmo-msc --version
	osmo-pcu --version
	osmo-sgsn --version
	osmo-sip-connector -h
	osmo-stp --version
	osmo-trx-uhd -h
	osmo-trx-usrp1 -h
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
