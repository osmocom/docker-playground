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
		telnet \
		libosmocore-dev && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_GGSN_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-ggsn.git
ADD	http://git.osmocom.org/osmo-ggsn/patch/?h=$OSMO_GGSN_BRANCH /tmp/commit
RUN	cd osmo-ggsn && \
	git fetch && git checkout -f -B $OSMO_GGSN_BRANCH origin/$OSMO_GGSN_BRANCH && \
	autoreconf -fi && \
	./configure && \
	make -j8 install && \
	ldconfig

VOLUME	/data

COPY	osmo-ggsn.cfg /data/osmo-ggsn.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-ggsn"]

EXPOSE	3386/udp 2123/udp 2152/udp 4257/tcp 4260/tcp
