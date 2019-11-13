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
		libasn1c-dev \
		libdbd-sqlite3 \
		libdbi-dev \
		libosmo-abis-dev \
		libosmo-mgcp-client-dev \
		libosmo-gsup-client-dev \
		libosmo-netif-dev \
		libosmo-ranap-dev \
		libosmo-sccp-dev \
		libosmo-sigtran-dev \
		libosmocore-dev \
		libsmpp34-dev \
		telnet && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_MSC_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-msc.git
ADD	http://git.osmocom.org/osmo-msc/patch?h=$OSMO_MSC_BRANCH /tmp/commit-osmo-msc

RUN	cd osmo-msc && \
	git fetch && git checkout $OSMO_MSC_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_MSC_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-smpp --enable-iu && \
	make -j8 install

VOLUME	/data

COPY	osmo-msc.cfg /data/osmo-msc.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-msc -c /data/osmo-msc.cfg >/data/osmo-msc.log 2>&1"]

#EXPOSE
