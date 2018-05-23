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
		libasn1c-dev \
		libdbd-sqlite3 \
		libdbi-dev \
		libosmo-abis-dev \
		libosmo-legacy-mgcp-dev \
		libosmo-mgcp-client-dev \
		libosmo-netif-dev \
		libosmo-ranap-dev \
		libosmo-sccp-dev \
		libosmo-sigtran-dev \
		libosmocore-dev \
		libsmpp34-dev \
		telnet && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_SIP_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-sip-connector.git
ADD	http://git.osmocom.org/osmo-sip-connector/patch?h=$OSMO_SIP_BRANCH /tmp/commit-osmo-sip-connector

RUN	cd osmo-sip-connector && \
	git fetch && git checkout -f -B $OSMO_SIP_BRANCH origin/$OSMO_SIP_BRANCH && \
	autoreconf -fi && \
	./configure --enable-smpp --enable-iu && \
	make -j8 install

VOLUME	/data

COPY	osmo-sip-connector.cfg /data/osmo-sip-connector.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-sip-connector"]

#EXPOSE	
