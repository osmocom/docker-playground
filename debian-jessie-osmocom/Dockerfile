FROM debian:jessie

MAINTAINER Harald Welte <laforge@gnumonks.org>

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_8.0/ ./" > /etc/apt/sources.list.d/osmocom-nightly.list

RUN	apt-get update && apt-get install -y \
	telnet \
	osmocom-sgsn \
	osmocom-nitb \
	osmocom-ipaccess-utils \
	osmocom-gbproxy \
	osmocom-bsc \
	osmocom-bsc-nat \
	osmocom-bs11-utils \
	openggsn \
	osmo-bts-trx \
	osmo-trx \
	osmo-pcu \
	osmo-sip-connector
