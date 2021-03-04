ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libosmocore-dev \
		libosmo-abis-dev \
		libosmo-netif-dev \
		libosmo-sccp-dev \
		libsmpp34-dev \
		libgtp-dev && \
	apt-get clean

WORKDIR	/tmp

ARG	OSMO_NITB_BRANCH="master"

RUN	git clone git://git.osmocom.org/openbsc.git
ADD	http://git.osmocom.org/openbsc/patch?h=$OSMO_NITB_BRANCH /tmp/commit-openbsc

RUN	cd openbsc/openbsc && \
	git fetch && git checkout $OSMO_NITB_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_NITB_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure --enable-nat --enable-osmo-bsc --enable-smpp && \
	make "-j$(nproc)" install && \
	ldconfig

VOLUME	/data

COPY	openbsc.cfg /data/openbsc.cfg
COPY	osmo-bsc-nat.cfg /data/osmo-bsc-nat.cfg
COPY	bscs.config /data/bscs.config

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-nitb -c /data/osmo-nitb.cfg >/data/osmo-nitb.log 2>&1"]

EXPOSE	3002/tcp 3003/tcp 4242/tcp 2775/tcp 4249/tcp
