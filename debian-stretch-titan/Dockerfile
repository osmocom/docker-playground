FROM debian:stretch

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/latest/Debian_9.0/"

RUN	apt-get update && apt-get install -y \
		gnupg

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-latest.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && apt-get install -y \
	eclipse-titan

RUN	apt-get update && \
	apt-get upgrade -y && \
	apt-get -y install \
		build-essential \
		git \
		tcpdump \
		vim \
		&& \
	apt-get clean

# somehow Debian folks updated the gcc version but not titan :/
RUN	sed -i 's/^#error/\/\/#error/' /usr/include/titan/cversion.h
