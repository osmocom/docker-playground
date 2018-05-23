FROM laforge/debian-jessie-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_8.0/"

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
		libosmo-sccp-dev && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_MGW_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-mgw.git
ADD	http://git.osmocom.org/osmo-mgw/patch?h=$OSMO_MGW_BRANCH /tmp/commit-osmo-mgw


RUN	cd osmo-mgw && \
	git fetch && git checkout -f -B $OSMO_MGW_BRANCH origin/$OSMO_MGW_BRANCH && \
	autoreconf -fi && \
	./configure && \
	make -j8 install && \
	ldconfig

VOLUME	/data

COPY	osmo-mgw.cfg /data/osmo-mgw.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-mgw"]
