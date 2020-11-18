ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:stretch
FROM	${REGISTRY}/${UPSTREAM_DISTRO}
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="$OSMOCOM_REPO_MIRROR/repositories/network:/osmocom:/latest/Debian_9.0/"

COPY	Release.key /tmp/Release.key

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		gnupg

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-latest.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		telnet \
		osmo-sgsn && \
	apt-get clean

WORKDIR	/tmp

VOLUME	/data
COPY	osmo-sgsn.cfg /data/osmo-sgsn.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-sgsn -c /data/osmo-sgsn.cfg >/data/osmo-sgsn.log 2>&1"]

EXPOSE	23000/udp 4245/tcp 4249/tcp 4246/tcp 4263/tcp
