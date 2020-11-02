ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:stretch

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/latest/Debian_9.0/"

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
		osmocom-nitb \
		osmocom-bsc-nat \
		libdbd-sqlite3 && \
	apt-get clean

WORKDIR	/tmp

VOLUME	/data

COPY	openbsc.cfg /data/openbsc.cfg
COPY	osmo-bsc-nat.cfg /data/osmo-bsc-nat.cfg
COPY	bscs.config /data/bscs.config

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/bin/osmo-nitb -c /data/osmo-nitb.cfg >/data/osmo-nitb.log 2>&1"]

EXPOSE	3002/tcp 3003/tcp 4242/tcp 2775/tcp 4249/tcp
