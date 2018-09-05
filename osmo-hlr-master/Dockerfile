ARG	USER
FROM	$USER/debian-jessie-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_8.0/"

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libdbd-sqlite3 \
		libosmo-abis-dev \
		libosmo-netif-dev \
		libosmo-sigtran-dev \
		libosmocore-dev \
		telnet && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_HLR_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-hlr.git
ADD	http://git.osmocom.org/osmo-hlr/patch?h=$OSMO_HLR_BRANCH /tmp/commit-osmo-hlr

RUN	cd osmo-hlr && \
	git fetch && git checkout -f -B $OSMO_HLR_BRANCH origin/$OSMO_HLR_BRANCH && \
	autoreconf -fi && \
	./configure && \
	make -j8 install

VOLUME	/data

COPY	osmo-hlr.cfg /data/osmo-hlr.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-hlr"]

#EXPOSE	
