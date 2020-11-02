ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:stretch

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/latest/Debian_9.0/"

COPY	Release.key /tmp/Release.key

ADD	$OSMOCOM_REPO/Release /tmp/Release
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
		osmo-pcu && \
	apt-get clean

ADD	respawn.sh /usr/local/bin/respawn.sh

WORKDIR	/tmp

VOLUME	/data

COPY	osmo-pcu.cfg /data/osmo-pcu.cfg

WORKDIR	/data
CMD	["/usr/bin/osmo-pcu"]

#EXPOSE	
