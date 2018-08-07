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
		libosmocore-dev && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_BB_BRANCH="master"

RUN	git clone git://git.osmocom.org/osmocom-bb.git
ADD	http://git.osmocom.org/osmocom-bb/patch?h=$OSMO_BB_BRANCH /tmp/commit

RUN	cd osmocom-bb/src/host/virt_phy && \
	git fetch && git checkout -f -B $OSMO_BB_BRANCH origin/$OSMO_BB_BRANCH && \
	autoreconf -fi && \
	./configure && \
	make -j8 install

VOLUME	/data

WORKDIR	/data
CMD	["/usr/local/sbin/virtphy","-s","/data/osmocom_l2"]

#EXPOSE	3002/tcp 3003/tcp 4242/tcp 2775/tcp 4249/tcp
