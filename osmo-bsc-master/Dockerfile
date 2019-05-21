ARG	USER
FROM	$USER/debian-stretch-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_9.0/"

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		telnet \
		libosmocore-dev \
		libosmo-abis-dev \
		libosmo-netif-dev \
		libosmo-sccp-dev \
		libosmo-sigtran-dev \
		libosmo-mgcp-client-dev \
		libgtp-dev && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_BSC_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-bsc.git
ADD	http://git.osmocom.org/osmo-bsc/patch?h=$OSMO_BSC_BRANCH /tmp/commit-osmo-bsc

RUN	cd osmo-bsc && \
	git fetch && git checkout -f -B $OSMO_BSC_BRANCH $OSMO_BSC_BRANCH && \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make -j8 install

VOLUME	/data

COPY	osmo-bsc.cfg /data/osmo-bsc.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-bsc"]

#EXPOSE	
