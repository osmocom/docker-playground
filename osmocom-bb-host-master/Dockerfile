ARG	USER
FROM	$USER/debian-stretch-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMO_BB_BRANCH="master"

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_9.0/"

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list

# python-enum34 is a dependecy of fake_trx as long we're using python2
ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libosmocore-dev python-enum34 && \
	apt-get clean

WORKDIR	/tmp

RUN	git clone git://git.osmocom.org/osmocom-bb.git

ADD	http://git.osmocom.org/osmocom-bb/patch?h=$OSMO_BB_BRANCH /tmp/commit
RUN	cd osmocom-bb && \
	git fetch && git checkout $OSMO_BB_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_BB_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD

RUN	cd osmocom-bb/src/host/trxcon && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

RUN	cd osmocom-bb/src/host/virt_phy && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

RUN	mkdir -p /data/unix

VOLUME	/data

WORKDIR	/data
#CMD	["/usr/local/sbin/virtphy","-s","/data/osmocom_l2"]
