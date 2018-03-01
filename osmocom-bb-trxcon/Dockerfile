FROM laforge/debian-jessie-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMO_BB_BRANCH="laforge/trx"

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_8.0/"

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		telnet \
		tcpdump \
		libosmocore-dev \
		libosmo-abis-dev \
		libosmo-netif-dev \
		libosmo-sccp-dev \
		libsmpp34-dev \
		libgtp-dev && \
	apt-get clean

WORKDIR	/tmp

RUN	git clone git://git.osmocom.org/osmocom-bb.git

ADD	http://git.osmocom.org/osmocom-bb/patch?h=$OSMO_BB_BRANCH /tmp/commit
RUN	cd osmocom-bb && \
	git fetch && git checkout -f -B $OSMO_BB_BRANCH origin/$OSMO_BB_BRANCH

RUN	cd osmocom-bb/src/host/trxcon && \
	autoreconf -fi && \
	./configure && \
	make -j8 install

RUN	mkdir -p /data/unix

VOLUME	/data

WORKDIR	/data
#CMD	["/usr/local/sbin/virtphy","-s","/data/osmocom_l2"]
