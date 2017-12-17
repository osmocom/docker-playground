FROM laforge/debian-stretch-build

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
		libosmo-sigtran-dev \
		libasn1c-dev && \
	apt-get clean

WORKDIR	/tmp

RUN	git clone git://git.osmocom.org/osmo-iuh.git
ADD	http://git.osmocom.org/osmo-iuh/patch /tmp/commit-osmo-mgw

RUN	cd osmo-iuh && \
	git fetch && git checkout -f -B master origin/master && \
	autoreconf -fi && \
	./configure && \
	make -j8 install && \
	ldconfig

VOLUME	/data

COPY	osmo-hnbgw.cfg /data/osmo-hnbgw.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-hnbgw", "-c", "/data/osmo-hnbgw.cfg"]
