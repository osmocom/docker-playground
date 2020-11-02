ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:jessie

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_8.0/"

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		telnet \
		osmo-sgsn \
		osmo-msc \
		osmo-mgw \
		osmo-gbproxy \
		osmo-bsc \
		osmo-ggsn \
		osmo-bts-trx \
		osmo-trx \
		osmo-pcu \
		osmo-sip-connector && \
	apt-get clean
