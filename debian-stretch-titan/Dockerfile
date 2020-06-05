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
RUN	apt-get update && \
	apt-get install -y --no-install-recommends --no-install-suggests \
		eclipse-titan

RUN	apt-get update && \
	apt-get upgrade -y && \
	apt-get -y install \
		build-essential \
		git \
		procps \
		tcpdump \
		vim \
		netcat-openbsd \
		&& \
	apt-get clean

# somehow Debian folks updated the gcc version but not titan :/
RUN	sed -i 's/^#error/\/\/#error/' /usr/include/titan/cversion.h


# binary-only transcoding library for RANAP/RUA/HNBAP to work around TITAN only implementing BER
RUN	apt-get update && \
	apt-get -y install wget
RUN	wget https://ftp.osmocom.org/binaries/libfftranscode/libfftranscode0_0.1_amd64.deb && \
	wget https://ftp.osmocom.org/binaries/libfftranscode/libfftranscode-dev_0.1_amd64.deb && \
	apt install ./libfftranscode0_0.1_amd64.deb ./libfftranscode-dev_0.1_amd64.deb && \
	rm libfftranscode*.deb
