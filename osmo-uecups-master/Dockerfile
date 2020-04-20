ARG	USER
FROM	$USER/debian-buster-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_10/"

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libjansson-dev \
		libnl-route-3-dev \
		libosmocore-dev \
		libosmo-netif-dev \
		libsctp-dev \
		strace && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_BSC_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-uecups.git
ADD	http://git.osmocom.org/osmo-uecups/patch?h=$OSMO_BSC_BRANCH /tmp/commit-osmo-uecups

RUN	cd osmo-uecups && \
	git fetch && git checkout $OSMO_BSC_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_BSC_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make -j8 install

VOLUME	/data

COPY	osmo-uecups-daemon.cfg /data/osmo-uecups-daemon.cfg

RUN	useradd -m --uid=1000 osmocom

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-uecups-daemon -c /data/osmo-uecups-daemon.cfg >/data/osmo-uecups-daemon.log 2>&1"]

#EXPOSE
