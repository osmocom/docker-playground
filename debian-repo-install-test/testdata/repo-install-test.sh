#!/bin/sh -ex

# Systemd services that must start up successfully after installing all packages (OS#3369)
# Disabled services:
# * osmo-ctrl2cgi (missing config: /etc/osmocom/ctrl2cgi.ini, OS#4108)
# * osmo-trap2cgi (missing config: /etc/osmocom/%N.ini, OS#4108)
# * osmo-ggsn (no tun device in docker)
SERVICES="
	osmo-bsc
	osmo-gbproxy
	osmo-gtphub
	osmo-hlr
	osmo-mgw
	osmo-msc
	osmo-pcap-client
	osmo-sip-connector
	osmo-stp
"
# Services working in nightly, but not yet in latest
# * osmo-pcap-server: service not included in osmo-pcap 0.0.11
# * osmo-sgsn: conflicts with osmo-gtphub config in osmo-sgsn 1.4.0
# * osmo-pcu: needs osmo-bts-virtual to start up properly
# * osmo-hnbgw: tries to listen on 10.23.24.1 in osmo-iuh 0.4.0
# * osmo-bts-virtual: unit id not matching osmo-bsc's config in osmo-bsc 1.4.0
SERVICES_NIGHTLY="
	osmo-pcap-server
	osmo-sgsn
	osmo-pcu
	osmo-hnbgw
	osmo-bts-virtual
"

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

configure_osmocom_repo() {
	echo "Configuring Osmocom repository"
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
	# Make sure that binares run at all and output a proper version
	test_binaries_version \
		osmo-bsc \
		osmo-bts-trx \
		osmo-bts-virtual \
		osmo-gbproxy \
		osmo-gtphub \
		osmo-ggsn \
		osmo-hlr \
		osmo-hlr-db-tool \
		osmo-hnbgw \
		osmo-mgw \
		osmo-msc \
		osmo-pcu \
		osmo-sgsn \
		osmo-sip-connector \
		osmo-stp \
		osmo-trx-uhd \
		osmo-trx-usrp1
}

services_check() {
	local service
	local services_feed="$SERVICES"
	local failed=""

	if [ "$FEED" = "nightly" ]; then
		services_feed="$services_feed $SERVICES_NIGHTLY"
	fi

	systemctl start $services_feed
	sleep 2

	for service in $services_feed; do
		if ! systemctl --no-pager -l -n 200 status $service; then
			failed="$failed $service"
		fi
	done

	systemctl stop $services_feed

	if [ -n "$failed" ]; then
		set +x
		echo
		echo "ERROR: services failed to start: $failed"
		echo
		exit 1
	fi
}

check_env
configure_osmocom_repo
install_repo_packages
test_binaries
services_check
