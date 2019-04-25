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
		libosmo-netif-dev && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_STP_BRANCH="master"

RUN	git clone git://git.osmocom.org/libosmo-sccp.git
ADD	http://git.osmocom.org/libosmo-sccp/patch?h=$OSMO_STP_BRANCH /tmp/commit
RUN	cd libosmo-sccp && \
	git fetch && git checkout -f -B $OSMO_STP_BRANCH $OSMO_STP_BRANCH && \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make -j8 install && \
	ldconfig

VOLUME	/data

COPY	osmo-stp.cfg /data/

CMD	["/usr/local/bin/osmo-stp", "-c", "/data/osmo-stp.cfg"]

EXPOSE	2905 14001 4239
