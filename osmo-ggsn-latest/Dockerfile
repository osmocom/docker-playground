ARG	REGISTRY=docker.io
ARG	UPSTREAM_DISTRO=debian:stretch
FROM	${REGISTRY}/${UPSTREAM_DISTRO}

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/latest/Debian_9.0/"

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
		osmo-ggsn && \
	apt-get clean

WORKDIR	/tmp

VOLUME	/data
COPY	osmo-ggsn.cfg /data/osmo-ggsn.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-ggsn -c /data/osmo-ggsn.cfg >/data/osmo-ggsn.log 2>&1"]

EXPOSE	3386/udp 2123/udp 2152/udp 4257/tcp 4260/tcp
