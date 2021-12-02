ARG	USER
ARG	DISTRO
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO
ARG	OSMOCOM_REPO_TESTSUITE_MIRROR="http://download.opensuse.org"

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMO_BB_BRANCH="master"

ARG	OSMOCOM_REPO="$OSMOCOM_REPO_TESTSUITE_MIRROR/repositories/network:/osmocom:/nightly/Debian_9.0/"

COPY	.common/Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libosmocore-dev && \
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
