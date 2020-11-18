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
		osmo-stp \
		telnet && \
	apt-get clean

WORKDIR	/data

VOLUME	/data
COPY	osmo-stp.cfg /data/

CMD	["/bin/sh", "-c", "/usr/bin/osmo-stp -c /data/osmo-stp.cfg >/data/osmo-stp.log 2>&1"]

EXPOSE	2905 14001 4239
