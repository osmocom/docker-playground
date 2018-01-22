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

RUN	git clone git://git.osmocom.org/osmo-msc.git
ADD	http://git.osmocom.org/osmo-msc/patch /tmp/commit-osmo-msc

RUN	cd osmo-msc && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure --enable-smpp --enable-iu && \
	make -j8 install

VOLUME	/data

COPY	osmo-msc.cfg /data/osmo-msc.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-msc"]

#EXPOSE	
