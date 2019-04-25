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
		libosmo-sigtran-dev \
		libasn1c-dev && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_IUH_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-iuh.git
ADD	http://git.osmocom.org/osmo-iuh/patch?h=$OSMO_IUH_BRANCH /tmp/commit-osmo-mgw

RUN	cd osmo-iuh && \
	git fetch && git checkout -f -B $OSMO_IUH_BRANCH $OSMO_IUH_BRANCH && \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make -j8 install && \
	ldconfig

VOLUME	/data

COPY	osmo-hnbgw.cfg /data/osmo-hnbgw.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-hnbgw", "-c", "/data/osmo-hnbgw.cfg"]
