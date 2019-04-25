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
		libosmocore-dev && \
	apt-get clean

ADD	respawn.sh /usr/local/bin/respawn.sh

WORKDIR	/tmp

ARG	OSMO_PCU_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmo-pcu.git
ADD	http://git.osmocom.org/osmo-pcu/patch?h=$OSMO_PCU_BRANCH /tmp/commit-osmo-pcu

RUN	cd osmo-pcu && \
	git fetch && git checkout -f -B $OSMO_PCU_BRANCH $OSMO_PCU_BRANCH && \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-trx && \
	make -j8 install

VOLUME	/data

COPY	osmo-pcu.cfg /data/osmo-pcu.cfg

WORKDIR	/data
CMD	["/usr/local/bin/osmo-pcu", "-i", "172.18.0.230"]

#EXPOSE	
